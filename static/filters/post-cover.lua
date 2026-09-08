-- Reuse an insight's editorial image as its article cover.
local function current_metadata(fallback)
  -- Frozen knitr output can retain an old image in its YAML header.
  local file = io.open(quarto.doc.input_file, "r")
  if not file then return fallback end
  local contents = file:read("*a")
  file:close()
  local header = contents:match("^(%-%-%-\r?\n.-\r?\n%-%-%-)")
  if not header then return fallback end
  return pandoc.read(header .. "\n", "markdown").meta
end

function Pandoc(doc)
  if not quarto.doc.is_format("html") or not doc.meta["art-cover"] then
    return nil
  end
  local metadata = current_metadata(doc.meta)
  local source = pandoc.utils.stringify(metadata.image or "")
  -- Any image under /static/images/art/ is editorial art; a post whose `image`
  -- points at a chart or a figure is not a cover candidate.
  if not source:match("^/static/images/art/") then
    quarto.log.warning(
      "post-cover: `art-cover` is set but `image` is not editorial art, so no "
      .. "cover was added (" .. quarto.doc.input_file .. ", image: "
      .. (source ~= "" and source or "<unset>") .. ")"
    )
    return nil
  end
  local alt = pandoc.utils.stringify(metadata["image-alt"] or "Ilustração editorial de arquitetura urbana")
  local cover = pandoc.Image({pandoc.Str(alt)}, source, "", pandoc.Attr("", {"post-cover-image"}, {
    {"loading", "eager"}, {"decoding", "async"}, {"width", "1536"}, {"height", "1024"}
  }))
  doc.blocks:insert(1, pandoc.Div({pandoc.Plain({cover})}, pandoc.Attr("", {"post-cover"})))
  return doc
end
