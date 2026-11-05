-- Use Pandoc's public AST API; no Quarto-version-specific internals.
local started = false
-- Metadata strings go into Typst code, not markup. Encode before Pandoc's
-- Typst writer adds markup escapes. Content fields (title, abstract, statements)
-- keep their normal writer handling, including intentional formatting.
local function typst_string(value)
  local text
  if type(value) == "string" then
    text = value
  else
    local handlers = {
      RawInline = function(el) return pandoc.Str(el.text) end,
      SoftBreak = function() return pandoc.Str("\n") end,
      LineBreak = function() return pandoc.Str("\n") end,
      Quoted = function(el)
        local quote = el.quotetype == "SingleQuote" and "'" or '"'
        return {pandoc.Str(quote), pandoc.Span(el.content), pandoc.Str(quote)}
      end,
    }
    if pandoc.utils.type(value) == "Blocks" then
      text = pandoc.utils.stringify(pandoc.Pandoc(value):walk(handlers))
    else
      text = pandoc.utils.stringify(pandoc.Span(value):walk(handlers))
    end
  end
  text = text:gsub("\\", "\\\\"):gsub('"', '\\"')
             :gsub("\r", "\\r"):gsub("\n", "\\n"):gsub("\t", "\\t")
  return pandoc.MetaInlines({pandoc.RawInline("typst", '"' .. text .. '"')})
end

local function encode(value)
  if type(value) == "boolean" then return value end
  local kind = pandoc.utils.type(value)
  if kind == "Inlines" or kind == "Blocks" or type(value) == "string" then
    return typst_string(value)
  end
  local result = {}
  for key, item in pairs(value) do result[key] = encode(item) end
  return result
end

function Meta(meta)
  -- Older Pandoc consumes these writer options without exposing corresponding
  -- template variables. Copy their effective values through public Lua APIs.
  meta["typstr-numbered"] = pandoc.MetaBool(PANDOC_WRITER_OPTIONS.number_sections)
  meta["typstr-toc-depth"] = pandoc.MetaString(tostring(PANDOC_WRITER_OPTIONS.toc_depth or 3))
  -- Apply header definitions before the publication show rule. Early Pandoc
  -- places header-includes after that rule, too late for a first disclaimer.
  meta["typstr-header-includes"] = meta["header-includes"]
  meta["header-includes"] = nil
  local strings = {}
  for _, key in ipairs({"typstR-extension-path", "papersize", "mainfont",
                         "section-numbering", "page-numbering", "typstR",
                         "by-author", "affiliations"}) do
    if meta[key] ~= nil then strings[key] = encode(meta[key]) end
  end
  meta["typstr-strings"] = pandoc.MetaMap(strings)
  local function annotate(value)
    local kind = pandoc.utils.type(value)
    if type(value) ~= "table" or kind == "Inlines" or kind == "Blocks" then return end
    local fields = {}
    for key, item in pairs(value) do
      if key == "id" or key == "ref" or key == "email" or key == "orcid" or
         ((key == "name" or key == "department") and
          (type(item) == "string" or pandoc.utils.type(item) == "Inlines" or pandoc.utils.type(item) == "Blocks")) then
        fields["typstr-" .. key] = typst_string(item)
      else
        annotate(item)
      end
    end
    for key, item in pairs(fields) do value[key] = item end
  end
  annotate(meta["by-author"])
  annotate(meta.affiliations)
  return meta
end

-- Inline CSL references need citeproc. Run it explicitly so early Quarto does
-- not feed cross-references to it, and unwrap resolved Cite nodes for the early
-- Typst writer (which otherwise emits native #cite calls for resolved content).
local function inline_references(doc)
  if not doc.meta["typstr-inline-citeproc"] then return doc end
  local prefixes = {fig=true, tbl=true, lst=true, tip=true, nte=true, wrn=true,
    imp=true, cau=true, thm=true, lem=true, cor=true, prp=true, cnj=true, def=true,
    exm=true, exr=true, sol=true, rem=true, alg=true, prf=true, eq=true, sec=true}
  local protected = {}
  local function crossref(citation)
    return prefixes[citation.id:lower():match("^([a-z]+)-")] == true
  end
  local function protect(cite)
    local id = "typstr-protected-crossref-" .. (#protected + 1)
    protected[#protected + 1] = cite
    return pandoc.Span({}, {id=id})
  end
  doc = doc:walk({Cite = function(cite)
    local has_crossref = false
    for _, citation in ipairs(cite.citations) do has_crossref = has_crossref or crossref(citation) end
    if not has_crossref then return nil end
    -- Keep contiguous bibliography citations grouped and preserve the order of
    -- cross-references when both types share a citation group.
    local groups, current, is_crossref = {}, {}, nil
    for _, citation in ipairs(cite.citations) do
      local kind = crossref(citation)
      if is_crossref ~= nil and kind ~= is_crossref then
        groups[#groups + 1] = {items=current, crossref=is_crossref}
        current = {}
      end
      current[#current + 1] = citation
      is_crossref = kind
    end
    groups[#groups + 1] = {items=current, crossref=is_crossref}
    if #groups == 1 then return protect(cite) end
    local inlines = {}
    for index, group in ipairs(groups) do
      if index > 1 then inlines[#inlines + 1] = pandoc.Str("; ") end
      local part = pandoc.Cite(cite.content, group.items)
      inlines[#inlines + 1] = group.crossref and protect(part) or part
    end
    return pandoc.Span(inlines)
  end})
  doc = pandoc.utils.citeproc(doc)
  doc = doc:walk({Cite = function(cite) return cite.content end})
  doc = doc:walk({Span = function(span)
    local index = span.identifier:match("^typstr%-protected%-crossref%-(%d+)$")
    if index then return protected[tonumber(index)] end
  end})
  -- Citeproc has emitted the complete bibliography into the body. Do not also
  -- ask the native Typst writer to append an external bibliography.
  doc.meta.bibliography = nil
  if PANDOC_VERSION < pandoc.types.Version("3.2") then
    -- Early Typst writers emit Div labels before their content, attaching CSL
    -- entry labels to the preceding element. Give each reference a real block.
    doc = doc:walk({Div = function(div)
      if div.identifier == "refs" or div.identifier:match("^ref%-") then
        local id = div.identifier:gsub("\\", "\\\\"):gsub('"', '\\"')
        div.identifier = ""
        div.content:insert(1, pandoc.RawBlock("typst", "#block["))
        div.content:insert(pandoc.RawBlock("typst", ']\n#label("' .. id .. '")'))
        return div
      end
    end})
  end
  return doc
end

function Pandoc(doc)
  started = false
  if FORMAT ~= "typst" then return doc end
  doc = inline_references(doc)
  return doc:walk({
    Header = function(header)
      if not started and header.classes:includes("appendix") then
        started = true
        return {pandoc.RawBlock("typst", "#show: rest => start-appendix(enabled: typstr-appendices-enabled, rest)"), header}
      end
    end
  })
end
