-- This is a JATS custom writer for pandoc.  It produces output
-- that tries to conform to the JATS 1.0 specification
-- http://jats.nlm.nih.gov/archiving/tag-library/1.0/index.html
--
-- Invoke with: pandoc -t JATS.lua
--
-- Note:  you need not have lua installed on your system to use this
-- custom writer.  However, if you do have lua installed, you can
-- use it to test changes to the script.  'lua JATS.lua' will
-- produce informative error messages if your code contains
-- syntax errors.

-- Character escaping
local function escape(s, in_attribute)
  return s:gsub("[<>&\"']",
    function(x)
      if x == '<' then
        return '&lt;'
      elseif x == '>' then
        return '&gt;'
      elseif x == '&' then
        return '&amp;'
      elseif x == '"' then
        return '&quot;'
      elseif x == "'" then
        return '&#39;'
      else
        return x
      end
    end)
end

-- Helper function to convert an attributes table into
-- a string that can be put into HTML tags.
local function attributes(attr)
  local attr_table = {}
  for x,y in pairs(attr) do
    if y and y ~= "" then
      table.insert(attr_table, ' ' .. x .. '="' .. escape(y,true) .. '"')
    end
  end
  return table.concat(attr_table)
end

-- Run cmd on a temporary file containing inp and return result.
local function pipe(cmd, inp)
  local tmp = os.tmpname()
  local tmph = io.open(tmp, "w")
  tmph:write(inp)
  tmph:close()
  local outh = io.popen(cmd .. " " .. tmp,"r")
  local result = outh:read("*all")
  outh:close()
  os.remove(tmp)
  return result
end

-- Table to store footnotes, so they can be included at the end.
local notes = {}

-- Blocksep is used to separate block elements.
function Blocksep()
  return "\n\n"
end

-- This function is called once for the whole document. Parameters:
-- body is a string, metadata is a table, variables is a table.
-- One could use some kind of templating
-- system here; this just gives you a simple standalone XML file.
function Doc(body, metadata, variables)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end

  -- put references into back
  local offset = string.find(body, '<ref-')
  if (offset == nil) then
    back = ''
  else
    back = string.sub(body, offset)
    body = string.sub(body, 1, offset - 1)
  end

  body = '<sec>\n<title/>' .. body .. '</sec>\n'

  article = metadata['article'] or {}
  journal = metadata['journal'] or {}
  publisher = metadata['publisher'] or {}

  -- variables required for validation
  if not (article['publisher-id'] or article['doi'] or article['pmid'] or article['pmcid'] or article['art-access-id']) then
    article['art-access-id'] = ''
  end
  if not (journal['pissn'] or journal['eissn']) then journal['eissn'] = '' end
  if not (journal['publisher-id'] or journal['nlm-ta'] or journal['pmc']) then
    journal['publisher-id'] = ''
  end
  if not journal['title'] then journal['title'] = '' end
  if not publisher['name'] then publisher['name'] = '' end

  -- defaults
  article['type'] = article['type'] or 'other'
  article['heading'] = article['heading'] or 'Other'
  article['elocation-id'] = article['elocation-id'] or article['doi'] or 'Other'

   -- use today's date if no pub-date in ISO 8601 format is given
  if not (article['pub-date'] and string.len(article['pub-date']) == 10) then
    article['pub-date'] = os.date('%Y-%m-%d')
  end

  add('<?xml version="1.0" encoding="UTF-8"?>')
  add('<!DOCTYPE article PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.0 20120330//EN" "http://jats.nlm.nih.gov/publishing/1.0/JATS-journalpublishing1.dtd">')
  add('<article xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" article-type="' ..
    article['type'] .. '" dtd-version="1.0">')
  add('<front>')

  add('<journal-meta>')
  if journal['publisher-id'] then
    add('<journal-id journal-id-type="publisher-id">' .. journal['publisher-id'] .. '</journal-id>')
  end
  if journal['nlm-ta'] then
    add('<journal-id journal-id-type="nlm-ta">' .. journal['nlm-ta'] .. '</journal-id>')
  end
  if journal['pmc'] then
    add('<journal-id journal-id-type="pmc">' .. journal['pmc'] .. '</journal-id>')
  end
  add('<journal-title-group><journal-title>' .. journal['title'] .. '</journal-title></journal-title-group>')
  if journal['pissn'] then
    add('<issn pub-type="ppub">' .. journal['pissn'] .. '</issn>')
  end
  if journal['eissn'] then
    add('<issn pub-type="epub">' .. journal['eissn'] .. '</issn>')
    add('<issn-l>' .. journal['eissn'] .. '</issn-l>')
  end
  add('<publisher>')
  add('<publisher-name>' .. publisher['name'] .. '</publisher-name>')
  if publisher['loc'] then
    add('<publisher-loc>' .. publisher['loc'] .. '</publisher-loc>')
  end
  add('</publisher>')
  add('</journal-meta>')

  add('<article-meta>')
  if article['publisher-id'] then
    add('<article-id pub-id-type="publisher-id">' .. article['publisher-id'] .. '</article-id>')
  end
  if article['doi'] then
    add('<article-id pub-id-type="doi">' .. article['doi'] .. '</article-id>')
  end
  if article['pmid'] then
    add('<article-id pub-id-type="pmid">' .. article['pmid'] .. '</article-id>')
  end
  if article['pmcid'] then
    add('<article-id pub-id-type="pmcid">' .. article['pmcid'] .. '</article-id>')
  end
  if article['art-access-id'] then
    add('<article-id pub-id-type="art-access-id">' .. article['art-access-id'] .. '</article-id>')
  end

  add('<article-categories>')
  add('<subj-group subj-group-type="heading">')
  add('<subject>' .. article['heading'] .. '</subject>')
  add('</subj-group>')
  if metadata['categories'] then
    add('<subj-group subj-group-type="categories">')
    for _, category in pairs(metadata['categories']) do
      add('<subject>' .. category .. '</subject>')
    end
    add('</subj-group>')
  end
  add('</article-categories>')

  add('<title-group><article-title>' .. (metadata['title'] or '') .. '</article-title></title-group>')
  if metadata['authors'] then
    add('<contrib-group content-type="authors">')
    for i, author in pairs(metadata['authors']) do
      add('<contrib id="author-' .. i .. '" contrib-type="author"' ..
        (author['corresp'] and ' corresp="yes"' or '') .. '>')
      if author['orcid'] then
        add('<contrib-id contrib-id-type="orcid">' .. author['orcid'] .. '</contrib-id>')
      end
      add('<name>')
      add('<surname>' .. (author['surname'] or '') .. '</surname>')
      add('<given-names>' .. (author['given-names'] or '') .. '</given-names>')
      add('</name>')
      add('<email>' .. (author['email'] or '') .. '</email>')

      add('</contrib>')
    end
    add('</contrib-group>')
  end

  if metadata['editors'] then
    add('<contrib-group content-type="editors">')
    for i, editor in pairs(metadata['editors']) do
      add('<contrib id="editor-' .. i .. '" contrib-type="editor">')
      add('<name>')
      add('<surname>' .. (editor['surname'] or '') .. '</surname>')
      add('<given-names>' .. (editor['given-names'] or '') .. '</given-names>')
      add('</name>')
      add('<email>' .. (editor['email'] or '') .. '</email>')
      add('</contrib>')
    end
    add('</contrib-group>')
  end

  add('<pub-date pub-type="epub" date-type="pub" iso-8601-date="' .. article['pub-date'] .. '">')
  add('<day>' .. string.sub(article['pub-date'], 9, 10) .. '</day>')
  add('<month>' .. string.sub(article['pub-date'], 6, 7) .. '</month>')
  add('<year>' .. string.sub(article['pub-date'], 1, 4) .. '</year>')
  add('</pub-date>')

  add('<elocation-id>' .. article['elocation-id'] .. '</elocation-id>')

  add('</article-meta>')
  add('</front>')

  add('<body>' .. body .. '</body>')
  add('<back>' .. back .. '</back>')

  add('</article>')
  return table.concat(buffer,'\n')
end

-- The functions that follow render corresponding pandoc elements.
-- s is always a string, attr is always a table of attributes, and
-- items is always an array of strings (the items in a list).
-- Comments indicate the types of other variables.

function Str(s)
  return escape(s)
end

function Space()
  return " "
end

function LineBreak()
  return "<br/>"
end

function Emph(s)
  return "<italic>" .. s .. "</italic>"
end

function Strong(s)
  return "<bold>" .. s .. "</bold>"
end

function Subscript(s)
  return "<sub>" .. s .. "</sub>"
end

function Superscript(s)
  return "<sup>" .. s .. "</sup>"
end

function SmallCaps(s)
  return s
end

function Strikeout(s)
  return '<strike>' .. s .. '</strike>'
end

function Link(s, src, tit)
  return '<ext-link ext-link-type="uri" xlink:href="' .. escape(src,true) .. '" xlink:type="simple">' .. s .. '</ext-link>'
end

function Image(src, tit, s)
  -- if s begins with <bold> text, make it the <title>
  s = string.gsub('<p>' .. s, "^<bold>(.-)</bold>%s", "<title>%1</title>\n<p>")
  return '<fig>\n' ..
         '<caption>\n' .. s .. '</p>\n</caption>\n' ..
         "<graphic mimetype='image' xlink:href='".. escape(src,true) .. "' xlink:type='simple'/>\n" ..
         '</fig>'
end

function CaptionedImage(src, tit, s)
  -- if s begins with <bold> text, make it the <title>
  s = string.gsub('<p>' .. s, "^<p><bold>(.-)</bold>%s", "<title>%1</title>\n<p>")
  return '<fig>\n' ..
         '<caption>\n' .. s .. '</p>\n</caption>\n' ..
         "<graphic mimetype='image' xlink:href='".. escape(src,true) .. "' xlink:type='simple'/>\n" ..
         '</fig>'
end

function Code(s, attr)
  return "<preformat>" .. escape(s) .. "</preformat>"
end

function InlineMath(s)
  return "\\(" .. escape(s) .. "\\)"
end

function DisplayMath(s)
  return "\\[" .. escape(s) .. "\\]"
end

function Note(s)
  local num = #notes + 1
  -- insert the back reference right before the final closing tag.
  s = string.gsub(s,
          '(.*)</', '%1 <a href="#fnref' .. num ..  '">&#8617;</a></')
  -- add a list item with the note to the note table.
  table.insert(notes, '<li id="fn' .. num .. '">' .. s .. '</li>')
  -- return the footnote reference, linked to the note.
  return '<a id="fnref' .. num .. '" href="#fn' .. num ..
            '"><sup>' .. num .. '</sup></a>'
end

function Span(s, attr)
  return s
end

function Plain(s)
  return s
end

function Para(s)
  return "<p>" .. s .. "</p>"
end

function Cite(s)
  return s
end

-- lev is an integer, the header level.
function Header(lev, s, attr)
  if attr.id and string.match(' ' .. attr.id .. ' ',' references ') then
    return ''
  elseif attr.id then
    return '</sec>\n<sec id="' .. attr.id .. '">\n' ..
           '<title>' .. s .. '</title>'
  else
    return '</sec>\n<sec>\n' ..
           '<title>' .. s .. '</title>'
  end
end

function BlockQuote(s)
  return "<boxed-text>\n" .. s .. "\n</boxed-text>"
end

-- Should be restricted to use inside table cells (<td> and <th>)
function HorizontalRule()
  return "<hr/>"
end

function CodeBlock(s, attr)
  -- If code block has class 'dot', pipe the contents through dot
  -- and base64, and include the base64-encoded png as a data: URL.
  if attr.class and string.match(' ' .. attr.class .. ' ',' dot ') then
    local png = pipe("base64", pipe("dot -Tpng", s))
    return '<img src="data:image/png;base64,' .. png .. '"/>'
  -- otherwise treat as code (one could pipe through a highlighter)
  else
    return '<preformat>' .. escape(s) .. '</preformat>'
  end
end

function BulletList(items)
  local buffer = {}
  for _, item in pairs(items) do
    table.insert(buffer, "<list-item><p>" .. item .. "</p></list-item>")
  end
  return '<list list-type="bullet">\n' .. table.concat(buffer, "\n") .. '\n</list>'
end

function OrderedList(items)
  local buffer = {}
  for _, item in pairs(items) do
    table.insert(buffer, "<list-item><p>" .. item .. "</p></list-item>")
  end
  return '<list list-type="order">\n' .. table.concat(buffer, "\n") .. '\n</list>'
end

-- Revisit association list STackValue instance.
function DefinitionList(items)
  local buffer = {}
  for _,item in pairs(items) do
    for k, v in pairs(item) do
      table.insert(buffer,"<dt>" .. k .. "</dt>\n<dd>" ..
                        table.concat(v,"</dd>\n<dd>") .. "</dd>")
    end
  end
  return "<dl>\n" .. table.concat(buffer, "\n") .. "\n</dl>"
end

-- Convert pandoc alignment to something HTML can use.
-- align is AlignLeft, AlignRight, AlignCenter, or AlignDefault.
function html_align(align)
  if align == 'AlignLeft' then
    return 'left'
  elseif align == 'AlignRight' then
    return 'right'
  elseif align == 'AlignCenter' then
    return 'center'
  else
    return 'left'
  end
end

-- Caption is a string, aligns is an array of strings,
-- widths is an array of floats, headers is an array of
-- strings, rows is an array of arrays of strings.
function Table(caption, aligns, widths, headers, rows)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end
  add("<table-wrap>\n")
  if caption ~= "" then
    -- if caption begins with <bold> text, make it the <title>
    caption = string.gsub('<p>' .. caption, "^<p><bold>(.-)</bold>%s", "<title>%1</title>\n<p>")
    add('<caption>\n' .. caption .. '</p>\n</caption>\n')
  end
  add("<table>")
  if widths and widths[1] ~= 0 then
    for _, w in pairs(widths) do
      add('<col width="' .. string.format("%d%%", w * 100) .. '" />')
    end
  end
  local header_row = {}
  local empty_header = true
  for i, h in pairs(headers) do
    local align = html_align(aligns[i])
    table.insert(header_row,'<th align="' .. align .. '">' .. h .. '</th>')
    empty_header = empty_header and h == ""
  end
  if empty_header then
    head = ""
  else
    add('<tr>')
    for _,h in pairs(header_row) do
      add(h)
    end
    add('</tr>')
  end
  for _, row in pairs(rows) do
    add('<tr>')
    for i,c in pairs(row) do
      -- remove <p> tag
      c = string.gsub(c, "^<p>(.-)</p>", "%1")
      add('<td align="' .. html_align(aligns[i]) .. '">' .. c .. '</td>')
    end
    add('</tr>')
  end
  add('</table>\n</table-wrap>')
  return table.concat(buffer,'\n')
end

function Div(s, attr)
  -- parse references
  if attr.class and string.match(' ' .. attr.class .. ' ',' references ') then
    local i = 0
    s = string.gsub(s, "<p>(.-)</p>", function (c)
          i = i + 1
          return '<ref id="ref-' .. i .. '">\n<mixed-citation>' .. c .. '</mixed-citation>\n</ref>'
        end)
    return '<ref-list>\n<title>References</title>\n' .. s .. '\n</ref-list>'
  else
    return s
  end
end

function Reference(s)
  return s
  --return '<ref>\n<mixed-citation>' .. s .. '</mixed-citation>\n</ref>'
end

-- The following code will produce runtime warnings when you haven't defined
-- all of the functions you need for the custom writer, so it's useful
-- to include when you're working on a writer.
local meta = {}
meta.__index =
  function(_, key)
    io.stderr:write(string.format("WARNING: Undefined function '%s'\n",key))
    return function() return "" end
  end
setmetatable(_G, meta)