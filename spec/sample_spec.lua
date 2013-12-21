require("../sample")

describe("required custom writer functions", function()

  -- generic writer functions
  it("Doc", function()
    assert.is_true(type(Doc) == 'function')
  end)

  it("Blocksep", function()
    assert.is_true(type(Blocksep) == 'function')
  end)

  -- block elements
  it("Plain", function()
    assert.is_true(type(Plain) == 'function')
  end)

   it("CaptionedImage", function()
    assert.is_true(type(CaptionedImage) == 'function')
  end)

  it("Para", function()
    assert.is_true(type(Para) == 'function')
  end)

  it("RawBlock", function()
    assert.is_true(type(RawBlock) == 'function')
  end)

  it("HorizontalRule", function()
    assert.is_true(type(HorizontalRule) == 'function')
  end)

  it("Header", function()
    assert.is_true(type(Header) == 'function')
  end)

  it("CodeBlock", function()
    assert.is_true(type(CodeBlock) == 'function')
  end)

  it("BlockQuote", function()
    assert.is_true(type(BlockQuote) == 'function')
  end)

  it("Table", function()
    assert.is_true(type(Table) == 'function')
  end)

  it("BulletList", function()
    assert.is_true(type(BulletList) == 'function')
  end)

  it("OrderedList", function()
    assert.is_true(type(OrderedList) == 'function')
  end)

  it("DefinitionList", function()
    assert.is_true(type(DefinitionList) == 'function')
  end)

  it("Div", function()
    assert.is_true(type(Div) == 'function')
  end)

  -- inline elements
  it("Str", function()
    assert.is_true(type(Str) == 'function')
  end)

  it("Space", function()
    assert.is_true(type(Space) == 'function')
  end)

  it("Emph", function()
    assert.is_true(type(Emph) == 'function')
  end)

  it("Strong", function()
    assert.is_true(type(Strong) == 'function')
  end)

  it("Strikeout", function()
    assert.is_true(type(Strikeout) == 'function')
  end)

  it("Superscript", function()
    assert.is_true(type(Superscript) == 'function')
  end)

  it("Subscript", function()
    assert.is_true(type(Subscript) == 'function')
  end)

  it("SmallCaps", function()
    assert.is_true(type(SmallCaps) == 'function')
  end)

  it("SingleQuoted", function()
    assert.is_true(type(SingleQuoted) == 'function')
  end)

  it("DoubleQuoted", function()
    assert.is_true(type(DoubleQuoted) == 'function')
  end)

  it("Cite", function()
    assert.is_true(type(Cite) == 'function')
  end)

  it("Code", function()
    assert.is_true(type(Code) == 'function')
  end)

  it("DisplayMath", function()
    assert.is_true(type(DisplayMath) == 'function')
  end)

  it("InlineMath", function()
    assert.is_true(type(InlineMath) == 'function')
  end)

  it("RawInline", function()
    assert.is_true(type(RawInline) == 'function')
  end)

  it("LineBreak", function()
    assert.is_true(type(LineBreak) == 'function')
  end)

  it("Link", function()
    assert.is_true(type(Link) == 'function')
  end)

  it("Image", function()
    assert.is_true(type(Image) == 'function')
  end)

  it("Note", function()
    assert.is_true(type(Note) == 'function')
  end)

  it("Span", function()
    assert.is_true(type(Span) == 'function')
  end)

end)