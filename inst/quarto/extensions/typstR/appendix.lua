-- Use Pandoc's public AST API; no Quarto-version-specific internals.
local started = false
function Meta(meta)
  -- Older Pandoc consumes these writer options without exposing corresponding
  -- template variables. Copy their effective values through public Lua APIs.
  meta["typstr-numbered"] = pandoc.MetaBool(PANDOC_WRITER_OPTIONS.number_sections)
  meta["typstr-toc-depth"] = pandoc.MetaString(tostring(PANDOC_WRITER_OPTIONS.toc_depth or 3))
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
