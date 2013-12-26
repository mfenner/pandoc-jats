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

-- XML character entity escaping and unescaping
function escape(s)
  local map = { ['<'] = '&lt;',
                ['>'] = '&gt;',
                ['&'] = '&amp;',
                ['"'] = '&quot;',
                ['\'']= '&#39;' }
  return s:gsub("[<>&\"']", function(x) return map[x] end)
end

function unescape(s)
  local map = { ['&lt;'] = '<',
                ['&gt;'] = '>',
                ['&amp;'] = '&',
                ['&quot;'] = '"',
                ['&#39;']= '\'' }
  return s:gsub('(&(#?)([%d%a]+);)', function(x) return map[x] end)
end

-- Helper function to convert an attributes table into
-- a string that can be put into XML elements.
function attributes(attr)
  local attr_table = {}
  for x,y in pairs(attr) do
    if y and y ~= "" then
      table.insert(attr_table, string.format(' %s="%s"', x, escape(y)))
    end
  end
  return table.concat(attr_table)
end

-- Flatten nested table, needed for nested YAML metadata['
-- We only flatten associative arrays and create composite key,
-- numbered arrays and flat tables are left intact.
-- We also convert all hyphens in keys to underscores,
-- so that they are proper variable names
function flatten_table(tbl)
  local result = {}

  local function flatten(tbl, key)
    for k, v in pairs(tbl) do
      if type(k) == 'number' and k > 0 and k <= #tbl then
        result[key] = tbl
        break
      else
        k = (key and key .. '-' or '') .. k
        if type(v) == 'table' then
          flatten(v, k)
        else
          result[k] = v
        end
      end
    end
  end

  flatten(tbl)
  return result
end

-- Read a file from the working directory and
-- return its contents (or nil if not found).
function read_file(name)
  local base, ext = name:match("([^%.]*)(.*)")
  local fname = base .. ext
  local file = io.open(fname, "read")
  if not file then
    file = io.open("templates/" .. fname, "read")
  end
  if not file then return nil end
  return file:read("*all")
end

-- Parse YAML string and return table.
-- We only understand a subset.
function parse_yaml(s)
  local l = {}
  local c = {}
  local i = 0
  local k = nil

  -- patterns
  line_pattern = '(.-)\r?\n'
  config_pattern = '^(%s*)([%w%-]+):%s*(.-)$'

  -- First split string into lines
  local function lines(line)
    table.insert(l, line)
    return ""
  end

  lines((s:gsub(line_pattern, lines)))

  -- Then go over each line and check value and indentation
  for _, v in ipairs(l) do
    v:gsub(config_pattern, function(indent, tag, v)
      if (v == '') then
        i, k = string.len(indent), tag
        c[tag] = {}
      else
        -- check whether value is enclosed by brackets, i.e. an array
        if v:find('^%[(.-)%]$') then
          arr = {};
          for match in (v:sub(2, -2) .. ','):gmatch('(.-)' .. ',%s*') do
              table.insert(arr, match);
          end
          v = arr;
        else
          -- if it is a string, remove optional enclosing quotes
          v = v:match('^["\']*(.-)["\']*$')
        end

        if string.len(indent) == i + 2 and k then
          c[k][tag] = v
        else
          c[tag] = v
        end
      end
    end)
  end

  return c
end

-- String substitution for Pandoc templates,
-- observing if/endif, for/endfor and variable attributes.
function fill_template(template, data)

  -- patterns
  condition_pattern = '%$if%(([%a%-][%w%-]*%.*[%w%-]*)%)%$%s*\n%s*(.-)%$endif%$%s*\n%s*'
  loop_pattern = '%$for%(([%a%-][%w%-]*)%)%$%s*\n%s*(.-)%$endfor%$%s*\n%s*'

  -- check conditionals
  template = template:gsub(condition_pattern, function(tag, s)
               return data[tag] and s or ''
             end)

  -- check loops
  template = template:gsub(loop_pattern, function(tag, s)
               r = ''
               if data[tag] then
                 for i, t in ipairs(data[tag]) do
                   r = r .. fill_template(s, { [tag] = t })
                 end
               end
               return r
             end)

  -- insert values and attributes
  template = template:gsub('%$([%a%-][%w%-]*%.*[%w%-]*)%$', function(w)
             local offset = w:find('%.')
             if offset then
               tag = w:sub(1, offset - 1)
               attr = w:sub(offset + 1)
               return data[tag] and data[tag][attr] or ''
             else
               return data[w] or ''
             end
           end)

  return template
end

-- Create table with year, month, day and iso8601-formatted date
-- Input is iso8601-formatted date as string
-- Return nil if input is not a valid date
function date_helper(iso_date)
  if not iso_date or string.len(iso_date) ~= 10 then return nil end

  _,_,y,m,d = string.find(iso_date, '(%d+)-(%d+)-(%d+)')
  time = os.time({ year = y, month = m, day = d })
  date = os.date('*t', time)
  date.iso8601 = string.format('%04d-%02d-%02d', date.year, date.month, date.day)
  return date
end

-- temporary fix
function fix_citeproc(s)
  s = s:gsub('</surname>, ', '</surname>')
  s = s:gsub('</name></name><name>','</name>')
  return s
end


-- Convert pandoc alignment to something HTML can use.
-- align is AlignLeft, AlignRight, AlignCenter, or AlignDefault.
function html_align(align)
  if align == 'AlignRight' then
    return 'right'
  elseif align == 'AlignCenter' then
    return 'center'
  else
    return 'left'
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

-- Table to store footnotes, so they can be included at the end.
local notes = {}

-- This function is called once for the whole document. Parameters:
-- body is a string, metadata is a table, variables is a table.
function Doc(body, metadata, variables)

  -- create new table that holds all metadata and document text
  -- start with some reasonable default values that can be overwritten
  local data = { ['pub-date'] = os.date('%Y-%m-%d'),
                 ['article-type'] = 'research-article',
                 ['article-heading'] = 'Article' }

  -- read YAML config file into table
  local config = read_file('config.yml')
  config = config and parse_yaml(config) or {}

  -- reuse some default metadata
  metadata['article-title'] = metadata['article-title'] or metadata['title']
  metadata['article-categories'] = metadata['article-categories'] or metadata['categories']
  metadata['kwd'] = metadata['kwd'] or metadata['tags']
  metadata['pub-date'] = metadata['pub-date'] or metadata['date']
  metadata['contrib'] = metadata['contrib'] or metadata['author']

  -- merge data from config file, metadata and variables
  -- overwrite value if key is the same in this order
  tables = { config, metadata, variables }
  for _,tbl in ipairs(tables) do
    for k,v in pairs(tbl) do data[k] = v end
  end

  -- flatten nested YAML metadata
  data = flatten_table(data)

  -- create date objects
  dates = { 'pub-date', 'date-received', 'date-accepted' }
  for _,d in ipairs(dates) do data[d] = date_helper(data[d]) end

  -- split of content that goes into back section
  -- add enclosing <sec> tags
  data.body = body
  local offset = data.body:find('<ref-')
  if offset then
    data.back = data.body:sub(offset)
    data.body = data.body:sub(1, offset - 1)
  end
  data.body = string.format('<sec>\n<title/>%s</sec>\n', data.body)
  if data.back then data.back = fix_citeproc(data.back) end

  if (data['date-received'] or data['date-accepted']) then
    data['history'] = true
  end

  -- parse template
  template = read_file('default.jats')
  result = template and fill_template(template, data) or ''
  return result
end

-- Blocksep is used to separate block elements.
function Blocksep()
  return "\n\n"
end

-- The functions that follow render corresponding pandoc elements.
-- s is always a string, attr is always a table of attributes, and
-- items is always an array of strings (the items in a list).
-- Comments indicate the types of other variables.
-- Defined at https://github.com/jgm/pandoc/blob/master/src/Text/Pandoc/Writers/Custom.hs

-- block elements

function Plain(s)
  return s
end

function CaptionedImage(src, tit, s)
  -- if s begins with <bold> text, make it the <title>
  s = string.gsub('<p>' .. s, "^<p><bold>(.-)</bold>%s", "<title>%1</title>\n<p>")
  return '<fig>\n' ..
         '<caption>\n' .. s .. '</p>\n</caption>\n' ..
         "<graphic mimetype='image' xlink:href='".. escape(src) .. "' xlink:type='simple'/>\n" ..
         '</fig>'
end

function Para(s)
  return "<p>" .. s .. "</p>"
end

function RawBlock(s)
  return "<preformat>" .. s .. "</preformat>"
end

-- JATS restricts use to inside table cells (<td> and <th>)
function HorizontalRule()
  return "<hr/>"
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

function CodeBlock(s, attr)
  return '<preformat>' .. escape(s) .. '</preformat>'
end

function BlockQuote(s)
  return "<boxed-text>\n" .. s .. "\n</boxed-text>"
end

-- Caption is a string, aligns is an array of strings,
-- widths is an array of floats, headers is an array of
-- strings, rows is an array of arrays of strings.
function Table(caption, aligns, widths, headers, rows)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end
  table.insert(buffer, '<table-wrap>\n')
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
      c = c:gsub("^<p>(.-)</p>", "%1")
      add('<td align="' .. html_align(aligns[i]) .. '">' .. c .. '</td>')
    end
    add('</tr>')
  end
  add('</table>\n</table-wrap>')
  return table.concat(buffer,'\n')
end

function BulletList(items)
  local buffer = {}
  for _, item in pairs(items) do
    table.insert(buffer, '<list-item><p>' .. item .. '</p></list-item>')
  end
  return '<list list-type="bullet">\n' .. table.concat(buffer, '\n') .. '\n</list>'
end

function OrderedList(items)
  local buffer = {}
  for _, item in pairs(items) do
    table.insert(buffer, '<list-item><p>' .. item .. '</p></list-item>')
  end
  return '<list list-type="order">\n' .. table.concat(buffer, '\n') .. '\n</list>'
end

-- Revisit association list STackValue instance.
function DefinitionList(items)
  local buffer = {}
  for _,item in pairs(items) do
    for k, v in pairs(item) do
      table.insert(buffer, '<def-item>\n<term>' .. k .. '</term>\n<def>' ..
                        table.concat(v,'</def>\n<def>') .. '</def>\n</def-item>')
    end
  end
  return '<def-list>\n' .. table.concat(buffer, '\n') .. '\n</def-list>'
end

function Div(s, attr)
  if attr.class and string.match(' ' .. attr.class .. ' ',' references ') then
    s = s:gsub("<p>(.-)</p>", '%1')
    return '<ref-list>\n<title>References</title>\n' .. s .. '\n</ref-list>'
  else
    return s
  end
end

-- inline elements

function Str(s)
  return s
end

function Space()
  return " "
end

function Emph(s)
  return "<italic>" .. s .. "</italic>"
end

function Strong(s)
  return "<bold>" .. s .. "</bold>"
end

function Strikeout(s)
  return '<strike>' .. s .. '</strike>'
end

function Superscript(s)
  return "<sup>" .. s .. "</sup>"
end

function Subscript(s)
  return "<sub>" .. s .. "</sub>"
end

function SmallCaps(s)
  return "<sc>" .. s .. "</sc>"
end

function SingleQuoted(s)
  return "'" .. s .. "'"
end

function DoubleQuoted(s)
  return '"' .. s .. '"'
end

function Cite(s)
  cite_table = {};
  for m in (s .. ','):gmatch('(.-)' .. ',') do
    table.insert(cite_table, string.format('<xref ref-type="bibr" rid="%s">%s</xref>', m, m))
  end
  return table.concat(cite_table)
end

function Code(s, attr)
  return "<preformat>" .. escape(s) .. "</preformat>"
end

function DisplayMath(s)
  return '<disp-formula>' .. escape(s) .. '</disp-formula>'
end

function InlineMath(s)
  return '<inline-formula>' .. escape(s) .. '</inline-formula>'
end

function RawInline(format, s)
  return "<preformat>" .. s .. "</preformat>"
end

function LineBreak()
  return "<br/>"
end

function Link(s, src, tit)
  -- TODO: disable parsing of links in the bibliography
  return s
  -- else
  --   return '<ext-link ext-link-type="uri" xlink:href="' .. escape(src) .. '" xlink:type="simple">' .. s .. '</ext-link>'
  -- end
end

function Image(src, tit, s)
  -- if s begins with <bold> text, make it the <title>
  s = string.gsub('<p>' .. s, "^<bold>(.-)</bold>%s", "<title>%1</title>\n<p>")
  return '<fig>\n' ..
         '<caption>\n' .. s .. '</p>\n</caption>\n' ..
         "<graphic mimetype='image' xlink:href='".. escape(src) .. "' xlink:type='simple'/>\n" ..
         '</fig>'
end

function Note(s)
  local num = #notes + 1
  -- insert the back reference right before the final closing tag.
  s = s:gsub('(.*)</', '%1 <a href="#fnref' .. num ..  '">&#8617;</a></')
  -- add a list item with the note to the note table.
  table.insert(notes, '<fn id="fn' .. num .. '">' .. s .. '</fn>')
  -- return the footnote reference, linked to the note.
  return '<a id="fnref' .. num .. '" href="#fn' .. num ..
            '"><sup>' .. num .. '</sup></a>'
end

function Span(s, attr)
  return s
end