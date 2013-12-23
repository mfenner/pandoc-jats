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

  it("substitute value", function()
    local template = '<body>$body$</body>'
    local data = { ['body'] = 'test' }
    assert.are.same(fill_template(template, data), '<body>test</body>')
  end)

  it("substitute attribute", function()
    local template = '<article article-type="$article_type$">Test</article>'
    local data = { ['article_type'] = 'research-article'}
    assert.are.same(fill_template(template, data), '<article article-type="research-article">Test</article>')
  end)

  it("substitute value for table", function()
    local template = '<article>$article.title$</article>'
    local data = { ['article'] = { title = 'test' }}
    assert.are.same(fill_template(template, data), '<article>test</article>')
  end)

  it("substitute value on condition", function()
    local template = '$if(body)$\n<body>$body$</body>\n$endif$'
    local data = { ['body'] = 'test' }
    result = fill_template(template, data)
    assert.are.same(result, '<body>test</body>\n')
  end)

  it("don't substitute value on failed condition", function()
    local template = '$if(body)$\n<body>$body$</body>\n$endif$'
    local data = {}
    assert.are.same(fill_template(template, data), '')
  end)

  it("substitute values in loop", function()
    local template = '$for(subject)$\n<subject>$subject$</subject>\n$endfor$'
    local data = { ['subject'] = { [1] = 'test', [2] = 'test2' }}
    assert.are.same(fill_template(template, data), '<subject>test</subject><subject>test2</subject>')
  end)

end)

describe("flatten", function()

  it("flatten_table", function()
    assert.is_true(type(flatten_table) == 'function')
  end)

  it("nested table", function()
    local data = { ['body'] = { ['name'] = 'test', ['color'] = '#CCC' }}
    local result = { ['body_name'] = 'test', ['body_color'] = '#CCC' }
    assert.are.same(flatten_table(data), data)
  end)

  it("regular table", function()
    local data = { ['body'] = 'test' }
    assert.are.same(flatten_table(data), data)
  end)

end)