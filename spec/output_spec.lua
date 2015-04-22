local inspect = require 'inspect'
require("../jats")

describe("custom writer functions", function()

  it("should escape XML entities", function()
    local result = escape('<')
    local expected = '&lt;'
    assert.are.same(result, expected)
  end)

  it("should unescape XML entities", function()
    local result = unescape('&lt;')
    expected = '<'
    assert.are.same(result, expected)
  end)

  it("function read_file exists", function()
    assert.is_true(type(read_file) == 'function')
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

describe("parse_yaml", function()

  it("function exists", function()
    assert.is_true(type(parse_yaml) == 'function')
  end)

  it("parse variables", function()
    local config = [[
    publisher-id: plos
    publisher-name: Public Library of Science
    ]]
    local expected = { ['publisher-id'] = 'plos',
                       ['publisher-name'] = 'Public Library of Science' }
    local result = parse_yaml(config)
    assert.are.same(result, expected)
  end)

  it("strip quotes", function()
    local config = [[
    title: "What Can Article Level Metrics Do for You?"
    alternate-title: 'What Can Article Level Metrics Do for You?'
    ]]
    local expected = { title = 'What Can Article Level Metrics Do for You?',
                       ['alternate-title'] = 'What Can Article Level Metrics Do for You?' }
    local result = parse_yaml(config)
    assert.are.same(result, expected)
  end)

  it("parse nested variables", function()
    local config = [[
    doi: 10.1371/journal.pbio.1001687
    journal:
      publisher-id: plos
    date: 2013-12-25
    publisher:
      publisher-name: Public Library of Science
    ]]
    local expected = { date = "2013-12-25",
                       doi = "10.1371/journal.pbio.1001687",
                       journal = {
                         ["publisher-id"] = "plos"
                       },
                       publisher = {
                         ["publisher-name"] = "Public Library of Science"
                       }
                     }
    local result = parse_yaml(config)
    assert.are.same(result, expected)
  end)

  it("parse array variable", function()
    local config = [[
    publisher-id: plos
    publisher-name: Public Library of Science
    tags: [molecular biology, cancer]
    ]]
    local expected = { ['publisher-id'] = 'plos',
                       ['publisher-name'] = 'Public Library of Science',
                       tags = { 'molecular biology', 'cancer' } }
    local result = parse_yaml(config)
    assert.are.same(result, expected)
  end)

end)
