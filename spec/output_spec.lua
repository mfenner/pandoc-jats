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

describe("Doc", function()
  it("should build the body", function()
    local result = Doc('This is a test.')
    expected = '<body>\n<sec id="sec-1">\n<title/>\nThis is a test.</sec>\n</body>'
    assert.are.same(result, expected)
  end)
end)

describe("xml builder", function()
  it("should build XML entities", function()
    local result = xml('p', 'Some text')
    expected = '<p>Some text</p>'
    assert.are.same(result, expected)
  end)

  it("should build self closing elements", function()
    local result = xml('hr')
    expected = '<hr/>'
    assert.are.same(result, expected)
  end)

  it("should include attributes", function()
    local result = xml('div', 'Some text', { ['id'] = 'results' })
    expected = '<div id="results">Some text</div>'
    assert.are.same(result, expected)
  end)
end)

describe("sections", function()
  it("should build header", function()
    local result = Header(2, 'Discussion')
    expected = '</sec>\n<sec lev="2">\n<title>Discussion</title>'
    assert.are.same(result, expected)
  end)

  it("should build section", function()
    local result = Section(2, 'Some text in the discussion.', 'Discussion', { ['sec-type'] = 'discussion' })
    expected = '<sec id="sec-1.1" sec-type="discussion">\n<title>Discussion</title>Some text in the discussion.</sec>'
    assert.are.same(result, expected)
  end)

  it("should build ack", function()
    local result = Ack('We thank our sponsors.')
    expected = '<ack>We thank our sponsors.</ack>'
    assert.are.same(result, expected)
  end)

  it("should build supplementary material", function()
    local result = SupplementaryMaterial('Detailed information about the experiment.', 'S4')
    expected = '<supplementary-material>\n<caption><title>S4</title>Detailed information about the experiment.</caption>\n</supplementary-material>'
    assert.are.same(result, expected)
  end)
end)

describe("references", function()
  it("should insert references", function()
    local result = Ref('<ref></ref>')
    expected = 1
    assert.are.same(result, expected)
  end)

  it("should build links", function()
    local result = Link('PubMed', 'http://www.ncbi.nlm.nih.gov/pubmed/', '24 million citations for biomedical literature')
    expected = '<ext-link ext-link-type="uri" xlink:href="http://www.ncbi.nlm.nih.gov/pubmed/" xlink:title="24 million citations for biomedical literature" xlink:type="simple">PubMed</ext-link>'
    assert.are.same(result, expected)
  end)
end)

describe("figures", function()
  it("should build graphic", function()
    local result = Image(nil, 'hello_world.png', 'A title')
    expected = '<graphic mimetype="image" xlink:href="hello_world.png" xlink:title="A title" xlink:type="simple"/>'
    assert.are.same(result, expected)
  end)

  it("should build graphic with object id", function()
    local object = xml('object_id', '12345')
    local result = Image(object, 'hello_world.png', 'A title')
    expected = '<graphic mimetype="image" xlink:href="hello_world.png" xlink:title="A title" xlink:type="simple"><object_id>12345</object_id></graphic>'
    assert.are.same(result, expected)
  end)

  it("should build figure", function()
    local title = xml('title', "Fig. 4")
    local result = CaptionedImage(title .. "Some describing text", 'hello_world.png', 'A title')
    expected = '<fig id="g001"><caption><title>Fig. 4</title>Some describing text</caption><graphic mimetype="image" xlink:href="hello_world.png" xlink:title="A title" xlink:type="simple"/></fig>'
    assert.are.same(result, expected)
  end)
end)

describe("custom tags", function()
  it("Section", function()
    assert.is_true(type(Section) == 'function')
  end)

  it("RefList", function()
    assert.is_true(type(RefList) == 'function')
  end)

  it("Ref", function()
    assert.is_true(type(Ref) == 'function')
  end)

  it("SupplementaryMaterial", function()
    assert.is_true(type(SupplementaryMaterial) == 'function')
  end)

  it("Ack", function()
    assert.is_true(type(Ack) == 'function')
  end)

  it("Glossary", function()
    assert.is_true(type(Glossary) == 'function')
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
