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

  it("function exists", function()
    assert.is_true(type(fill_template) == 'function')
  end)

  describe("inline elements", function()

    it("substitute value", function()
      local template = '<body>$body$</body>'
      local data = { body = 'test' }
      local expected = '<body>test</body>'
      local result = fill_template(template, data)
      assert.are.same(result, expected)
    end)

    it("substitute attribute", function()
      local template = '<article article-type="$article-type$">Test</article>'
      local data = { ['article-type'] = 'research-article'}
      local expected = '<article article-type="research-article">Test</article>'
      local result = fill_template(template, data)
      assert.are.same(result, expected)
    end)

    it("substitute value for table", function()
      local template = '<article>$article.title$</article>'
      local data = { article = { title = 'test' }}
      local expected = '<article>test</article>'
      local result = fill_template(template, data)
      assert.are.same(result, expected)
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
    local expected = { ['body-name'] = 'test', ['body-color'] = '#CCC' }
    local result = flatten_table(data)
    assert.are.same(result, expected)
  end)

  it("nested table with array", function()
    local data = { body = { name = 'test', color = '#CCC' }, author = {{ name = 'Smith' }, { name = 'Baker' }}}
    local expected = { ['body-name'] = 'test', ['body-color'] = '#CCC', author = {{ name = 'Smith' }, { name = 'Baker' }}}
    local result = flatten_table(data)
    assert.are.same(result, expected)
  end)

  it("deeply nested table", function()
    local data = { body = { name = 'test', font = { color = { id = 1, value = '#CCC' }}}}
    local expected = { ['body-name'] = 'test', ['body-font-color-id'] = 1, ['body-font-color-value'] = '#CCC' }
    local result = flatten_table(data)
    assert.are.same(result, expected)
  end)

  it("regular table", function()
    local data = { body = 'test' }
    local result = flatten_table(data)
    assert.are.same(result, data)
  end)

end)

describe("date_helper", function()

  it("function exists", function()
    assert.is_true(type(date_helper) == 'function')
  end)

  it("generates iso8601 dates", function()
    local date = '2013-12-24'
    local expected = '2013-12-24'
    local result = date_helper(date).iso8601
    assert.are.same(result, expected)
  end)

  it("rejects malformed dates", function()
    local date = '12/24/13'
    local expected = nil
    local result = date_helper(date)
    assert.are.same(result, expected)
  end)

end)