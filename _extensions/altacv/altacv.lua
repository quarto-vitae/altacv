--[[
  Render Markdown headings as AltaCV section headings.

  AltaCV names its heading commands \cvsection and \cvsubsection, leaving
  LaTeX's own \section alone. Bridging that here rather than by redefining
  \section in altacv.cls keeps the class a near-verbatim copy of upstream.

  Only levels 1 and 2 are remapped, because those are the only two the class
  styles. Level 3 and below fall through to extarticle's own \subsubsection.
]]

local function raw(s)
  return pandoc.RawInline("latex", s)
end

local function heading_command(level)
  if level == 1 then
    return "\\cvsection"
  elseif level == 2 then
    return "\\cvsubsection"
  end
end

function Header(el)
  if not FORMAT:match("latex") then
    return nil
  end

  local cmd = heading_command(el.level)
  if not cmd then
    return nil
  end

  -- Build the call around the heading's inlines rather than stringifying
  -- them, so emphasis, links and inline code in a heading survive.
  local inlines = pandoc.List({ raw(cmd .. "{") })
  inlines:extend(el.content)
  inlines:insert(raw("}"))

  -- \cvsection issues no \label of its own, unlike Awesome-CV's \cvsection.
  -- A cross-reference to a CV heading is a rare thing to want, so this is
  -- left unsupported rather than reaching into the class to add one.
  return pandoc.Plain(inlines)
end
