local inspect = require 'inspect'
require("../jats")

describe("custom writer functions", function()

  it("should escape XML entities", function()
    assert.are.same(escape('<'), '&lt;')
  end)

  it("find_template", function()
    assert.is_true(type(find_template) == 'function')
  end)

end)

describe("fill_template", function()

  it("fill_template", function()
    assert.is_true(type(fill_template) == 'function')
  end)

  describe("inline elements", function()

    it("substitute value", function()
      local template = '<body>$body$</body>'
      local data = { body = 'test' }
      local result = fill_template(template, data)
      assert.are.same(result, '<body>test</body>')
    end)

    it("substitute attribute", function()
      local template = '<article article-type="$article_type$">Test</article>'
      local data = { article_type = 'research-article'}
      local result = fill_template(template, data)
      assert.are.same(result, '<article article-type="research-article">Test</article>')
    end)

    it("substitute value for table", function()
      local template = '<article>$article.title$</article>'
      local data = { article = { title = 'test' }}
      local result = fill_template(template, data)
      assert.are.same(result, '<article>test</article>')
    end)

  end)

  describe("block elements", function()

    it("substitute value on condition", function()
      local template = [[
        $if(body)$
        <body>$body$</body>
        $endif$
        ]]
      local data = { body = 'test' }
      local expected = [[
        <body>test</body>
        ]]
      local result = fill_template(template, data)
      assert.are.same(result, expected)
    end)

    it("don't substitute value on failed condition", function()
      local template = [[
        $if(body)$
        <body>$body$</body>
        $endif$
        ]]
      local data = {}
      local expected = [[
        ]]
      local result = fill_template(template, data)
      assert.are.same(result, expected)
    end)

    it("substitute value for table on missing attribute", function()
      local template = [[
        $if(article)$
        <article>$article.title$</article>
        $endif$
        ]]
      local data = { article = {}}
      local expected = [[
        <article></article>
        ]]
      local result = fill_template(template, data)
      assert.are.same(result, expected)
    end)

    it("substitute values in loop", function()
      local template = [[
        $for(subject)$
        <subject>$subject$</subject>
        $endfor$
        ]]
      local data = { subject = { 'test', 'test2' }}
      local expected = [[
        <subject>test</subject>
        <subject>test2</subject>
        ]]
      local result = fill_template(template, data)
      assert.are.same(result, expected)
    end)

    it("substitute values for table in loop", function()
      local template = [[
        $for(subject)$
        <subject>$subject.name$</subject>
        $endfor$
        ]]
      local data = { subject = {{ name = 'test' }, { name = 'test2' }}}
      local expected = [[
        <subject>test</subject>
        <subject>test2</subject>
        ]]
      local result = fill_template(template, data)
      assert.are.same(result, expected)
    end)
  end)

end)

describe("flatten", function()

  it("flatten_table", function()
    assert.is_true(type(flatten_table) == 'function')
  end)

  it("nested table", function()
    local data = { body = { name = 'test', color = '#CCC' }}
    local expected = { body_name = 'test', body_color = '#CCC' }
    local result = flatten_table(data)
    assert.are.same(result, expected)
  end)

  it("nested table with array", function()
    local data = { body = { name = 'test', color = '#CCC' }, author = {{ name = 'Smith' }, { name = 'Baker' }}}
    local expected = { body_name = 'test', body_color = '#CCC', author = {{ name = 'Smith' }, { name = 'Baker' }}}
    local result = flatten_table(data)
    assert.are.same(result, expected)
  end)

  it("deeply nested table", function()
    local data = { body = { name = 'test', font = { color = { id = 1, value = '#CCC' }}}}
    local expected = { body_name = 'test', body_font_color_id = 1, body_font_color_value = '#CCC' }
    local result = flatten_table(data)
    assert.are.same(result, expected)
  end)

  it("regular table", function()
    local data = { body = 'test' }
    local result = flatten_table(data)
    assert.are.same(result, data)
  end)

end)