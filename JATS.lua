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
--
-- Released under the GPL, version 2 or greater. See LICENSE for more info.

-- Includes a modified version of Lua XML Builder
-- An easy-to-use XML generation library
-- http://pastie.org/1893954
--
----------------------------------------------------------------------------------
-- MIT License
--
-- Copyright (c) 2010 Evan Wies, neomantra at gmail dot com
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
----------------------------------------------------------------------------------

local string_format = string.format

local function generate_tag( tag, ... )
  -- create attribute string
  local tvararg = {...}
  local attr_str = ""
  local had_attrs = false
  if type(tvararg[1]) == 'table' then
    had_attrs = true
    for attr, val in pairs(tvararg[1]) do
      -- replace two underscores with colon in attribute name
      attr = attr:gsub("__", ":")

      -- replace underscores with hyphens in attribute name
      attr = attr:gsub("_", "-")

      attr_str = string_format('%s %s="%s"', attr_str, attr, val)
    end
  end

  -- replace underscores with hyphens in tag name
  tag = tag:gsub("_", "-")

  -- attribute-only or totally empty?
  if #tvararg == 0 or (#tvararg == 1 and had_attrs) then
    return ''
  -- value is empty string
  elseif (#tvararg == 1 or (#tvararg == 2 and had_attrs)) and tvararg[#tvararg] == '' then
    return string_format("<%s%s/>", tag, attr_str)
  end
  -- create full
  local result = string_format("<%s%s>", tag, attr_str)

  -- add declaration if root tag
  if tag == 'article' then
    result = '<!DOCTYPE article PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.0 20120330//EN" "JATS-journalpublishing1.dtd">' .. result
    result = '<?xml version="1.0" encoding="UTF-8"?>' .. result
  end

  for n, val in ipairs(tvararg) do
    if not (n == 1 and had_attrs) then
      result = result .. val
    end
  end
  return string_format("%s</%s>", result, tag)
end

-- tag names ending with '_pairs' contain multiple elements
local function generate_tags( tag, ... )
  local tvararg = {...}
  local s = ''
  if type(tvararg[1]) == 'table' then
    for i, v in ipairs(tvararg[1]) do
      if tvararg[2] == nil then
        s = s .. generate_tag(tag, v)
      else
        s = s .. generate_tag('contrib', { contrib_type = v['type'] or 'author' },
          generate_tag('contrib_id', { contrib_id_type = 'orcid' }, v['orcid']),
          generate_tag('name',
            generate_tag('surname', v['surname']),
            generate_tag('given_names', v['given-names'])
          ),
          generate_tag('email', v['email'])
        )
      end
    end
  end
  return s
end

local function generate_comment( ... )
  local comments = "<!-- "
  for _, v in ipairs{...} do
    comments = comments .. v
  end
  return comments .. " -->"
end

local function generate_cdata( ... )
  local cdata = "<![CDATA["
  for _, v in ipairs{...} do
    cdata = cdata .. v
  end
  return cdata .. "]]>"
end


local xml_builder_metatable = {
  __index = function( table, key )
    if key == "__comment" then
      return function( ... ) return generate_comment(...) end
    elseif key == "__cdata" then
      return function( ... ) return generate_cdata(...) end
    elseif string.sub(key, -6) == '_pairs' then
      key = string.sub(key, 1, -7)
      return function( ... ) return generate_tags(key, ...) end
    else
      return function( ... ) return generate_tag(key, ...) end
    end
  end,
}

-- the module table
local xml_builder = {}

function xml_builder.new( ... )
  -- the magic happens via metatables
  -- unless it is a special directive (__instruct, __comment),
  -- the __index metamethod returns a function which
  local tres = {}
  setmetatable( tres, xml_builder_metatable )
  return tres
end

-- end XML Builder library

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
  copyright = metadata['copyright'] or {}

  -- variables required for validation
  if not (article['publisher-id'] or article['doi'] or article['pmid'] or article['pmcid'] or article['art-access-id']) then
    article['art-access-id'] = ''
  end
  if not (journal['pissn'] or journal['eissn']) then journal['eissn'] = '' end
  if not (journal['publisher-id'] or journal['nlm-ta'] or journal['pmc']) then
    journal['publisher-id'] = ''
  end
  if not journal['title'] then journal['title'] = '' end

  -- defaults
  article['type'] = article['type'] or 'research-article'
  article['heading'] = article['heading'] or 'Other'
  article['elocation-id'] = article['elocation-id'] or article['doi'] or 'Other'
  article['title'] = metadata['title'] or 'Other'

   -- use today's date if no pub-date in ISO 8601 format is given
  if not (article['pub-date'] and string.len(article['pub-date']) == 10) then
    article['pub-date'] = os.date('%Y-%m-%d')
  end

  xml = xml_builder.new()

  return xml.article({ article_type = article['type'], xmlns__xlink = 'http://www.w3.org/1999/xlink' },
           xml.front(
             xml.journal_meta(
               xml.journal_id({ journal_id_type = 'publisher-id' }, journal['publisher-id']),
               xml.journal_id({ journal_id_type = 'nlm-ta' }, journal['nlm-ta']),
               xml.journal_id({ journal_id_type = 'pmc' }, journal['pmc']),
               xml.journal_title_group(
                 xml.journal_title(journal['title'])
               ),
               xml.issn({ pub_type = 'ppub' }, journal['pissn']),
               xml.issn({ pub_type = 'epub' }, journal['eissn']),
               xml.issn_l(journal['eissn']),
               xml.publisher(
                 xml.publisher_name((journal['publisher-name']  or '')),
                 xml.publisher_loc(journal['publisher-loc'])
               )
             ),
             xml.article_meta(
               xml.article_id({ pub_id_type = 'publisher-id' }, article['publisher-id']),
               xml.article_id({ pub_id_type = 'doi' }, article['doi']),
               xml.article_id({ pub_id_type = 'pmid' }, article['pmid']),
               xml.article_id({ pub_id_type = 'pmcid' }, article['pmcid']),
               xml.article_id({ pub_id_type = 'art-access-id' }, article['art-access-id']),
               xml.article_categories(
                 xml.subj_group({ subj_group_type = 'heading' },
                   xml.subject(article['heading'])
                   ),
                 xml.subj_group({ subj_group_type = 'categories' },
                   xml.subject_pairs(article['categories'])
                 )
               ),
               xml.title_group(
                 xml.article_title(article['title'])
               ),
               xml.contrib_group(
                 xml.contrib_pairs(metadata['contributors'],
                   xml.contrib_id(),
                   xml.name(
                     xml.surname(),
                     xml.given_names()
                   ),
                   xml.email()
                 )
               ),
               xml.pub_date({ pub_type = 'epub', iso_8601_date = article['pub-date'] },
                 xml.day(string.sub(article['pub-date'], 9, 10)),
                 xml.month(string.sub(article['pub-date'], 6, 7)),
                 xml.year(string.sub(article['pub-date'], 1, 4))
               ),
               xml.volume(article['volume']),
               xml.issue(article['issue']),
               xml.fpage(article['fpage']),
               xml.lpage(article['lpage']),
               xml.elocation_id(article['elocation-id']),
               xml.history(
                 xml.date({ date_type = 'received', iso_8601_date = article['received-date'] },
                   xml.day(article['received-date'] and string.sub(article['received-date'], 9, 10)),
                   xml.month(article['received-date'] and string.sub(article['received-date'], 6, 7)),
                   xml.year(article['received-date'] and string.sub(article['received-date'], 1, 4))
                 ),
                 xml.date({ date_type = 'accepted', iso_8601_date = article['accepted-date'] },
                   xml.day(article['accepted-date'] and string.sub(article['accepted-date'], 9, 10)),
                   xml.month(article['accepted-date'] and string.sub(article['accepted-date'], 6, 7)),
                   xml.year(article['accepted-date'] and string.sub(article['accepted-date'], 1, 4))
                 )
               ),
               xml.permissions(
                 xml.copyright_statement(copyright['statement']),
                 xml.copyright_year(copyright['year']),
                 xml.copyright_holder(copyright['holder']),
                 xml.license({ license_type = copyright['type'], xlink__href = copyright['link'] },
                   xml.license_p(copyright['text'])
                 )
               ),
               xml.kwd_group({ kwd_group_type = 'author' },
                 xml.kwd_pairs(metadata['tags'])
               )
             )
           ),
           xml.body(body),
           xml.back(back)
         )
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
  return "<sc>" .. s .. "</sc>"
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
  return '<inline-formula>' .. escape(s) .. '</inline-formula>'
end

function DisplayMath(s)
  return '<disp-formula>' .. escape(s) .. '</disp-formula>'
end

function Note(s)
  local num = #notes + 1
  -- insert the back reference right before the final closing tag.
  s = string.gsub(s,
          '(.*)</', '%1 <a href="#fnref' .. num ..  '">&#8617;</a></')
  -- add a list item with the note to the note table.
  table.insert(notes, '<fn id="fn' .. num .. '">' .. s .. '</fn>')
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
  return '<xref ref-type="bibr">' .. s .. '</xref>'
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
      table.insert(buffer,"<def-item>\n<term>" .. k .. "</term>\n<def>" ..
                        table.concat(v,"</def>\n<def>") .. "</def>\n</def-item>")
    end
  end
  return "<def-list>\n" .. table.concat(buffer, "\n") .. "\n</def-list>"
end

function SingleQuoted(s)
  return "'" .. s .. "'"
end

function DoubleQuoted(s)
  return '"' .. s .. '"'
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