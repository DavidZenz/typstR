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

function Pandoc(doc)
  started = false
  if FORMAT ~= "typst" then return doc end
  return doc:walk({
    Header = function(header)
      if not started and header.classes:includes("appendix") then
        started = true
        return {pandoc.RawBlock("typst", "#show: rest => start-appendix(enabled: typstr-appendices-enabled, rest)"), header}
      end
    end
  })
end
