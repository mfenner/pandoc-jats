require("../jats")

describe("required custom writer functions", function()

  it("should escape XML entities", function()
    assert.are.same(escape('<'), '&lt;')
  end)

end)

describe("generate XML tags", function()

  describe("check value and attributes", function()

    it("without value or attributes", function()
      assert.are.same(generate_tag('surname'), '')
    end)

    it("empty value without attributes", function()
      assert.are.same(generate_tag('surname', ''), '<surname/>')
    end)

    it("value without attributes", function()
      assert.are.same(generate_tag('surname', 'Smith'), '<surname>Smith</surname>')
    end)

    it("attributes without value", function()
      assert.are.same(generate_tag('surname', { lang = 'en' }), '')
    end)

    it("attributes wit empty value", function()
      assert.are.same(generate_tag('surname', { lang = 'en' }, ''), '<surname lang="en"/>')
    end)

    it("value and attributes", function()
      assert.are.same(generate_tag('surname', { lang = 'en' }, 'Smith'), '<surname lang="en">Smith</surname>')
    end)

  end)

  describe("substitute characters", function()

    it("substitute hypen in tag name", function()
      assert.are.same(generate_tag('journal_meta', ''), '<journal-meta/>')
    end)

    it("substitute hypen in attribute name", function()
      assert.are.same(generate_tag('article', { article_type = 'editorial' }, ''), '<article article-type="editorial"/>')
    end)

    it("substitute colon in attribute name", function()
      assert.are.same(generate_tag('article', { xmlns__xlink = 'http://www.w3.org/1999/xlink' }, ''), '<article xmlns:xlink="http://www.w3.org/1999/xlink"/>')
    end)

  end)

end)