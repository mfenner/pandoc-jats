---
layout: post
title: "Additional Markdown we need in Scholarly Texts"
description: ""
category: 
tags: [markdown]
---
Following up from [my post last
week](/2012/12/13/a-call-for-scholarly-markdown/),
below is a suggested list of features that should be supported in
documents written in scholarly markdown. Please provide feedback via the
comments, or by editing the Wiki version I have set up
[here](https://github.com/mfenner/scholarly-markdown/wiki). Listed are
features that go beyond the [standard markdown
syntax](http://daringfireball.net/projects/markdown/syntax).

The goals of scholarly markdown are

1.  to support writing of complete scholarly articles,
2.  don’t make the syntax more complicated than it is today, and
3.  don’t rely on HTML as the fallback mechanism.

In practice this means that scholarly markdown should support most, but
not all scholarly texts – documents that are heavy in math formulas,
have complicated tables, etc. may be better written with LaTeX or
Microsoft Word. It also means that scholarly markdown will probably
contain only limited semantic markup, as this is difficult to do with a
lightweight markup language and much easier with XML or a binary file
format.

Cover Page
----------

Optional metadata about a document. Typically used for title, authors
(including affiliation), and publication date, but should be flexible
enough to handle any kind of metadata (keywords, copyright, etc.).

```yaml
---
layout: post
title: "Additional Markdown we need in Scholarly Texts"
tags: [markdown]
authors:
 - name: Martin Fenner
   orcid: 0000-0003-1419-2405
copyright: http://creativecommons.org/licenses/by/3.0/deed.en
---
```

Typography
----------

Scholarly markdown should support ^superscript^ and ~subscript~ text, and
should provide an easy way to enter greek $\zeta$ letters.

Tables
------

Tables should work as anchors (i.e. you can link to them) and table
captions should support styled text. Unless the table is very simple,
tables are probably better written as CSV files with another tool, and
then imported into the scholarly markdown document similar to figures.

-----------------------------------------------------
 Centered             Right Left
  Header            Aligned Aligned
----------- --------------- -------------------------
   First               12.0 Example of a row that
                            spans multiple lines.

  Second                5.0 Here's another one. Note
                            the blank line between
                            rows.
-----------------------------------------------------

Table: **This is the table caption**. We can explain the table here.

Figures
-------

Figures in scholarly works are separated from the text, and have a
figure caption (which can contain styled text). Figures should work as
anchors (i.e. you can link to them). Figures can be in different file
formats, including TIFF and PDF, and those formats have to be converted
into web-friendly formats when exporting to HTML (e.g. PNG and SVG).

![**Set operations illustrated with Venn diagrams**. Example taken from [TeXample.net](http://www.texample.net/tikz/examples/set-operations-illustrated-with-venn-diagrams/).](/images/set-operations-illustrated-with-venn-diagrams.png)

Citations and Links
-------------------

Scholarly articles typically don’t have inline links, but rather
citations. The external links (both scholarly identifiers such as DOIs
and regular web URLs) are collected in a bibliography at the end of the
document, and the citations in the text link to this bibliography. This
functionality is similar to footnotes.

Citations should include a citation key in the text, e.g. `[@kowalczyk2011]`, parsed as [@kowalczyk2011], and a separate bibliography file in BibTeX (or RIS) format that contains references for all citations. Inserting citations and creating the bibliography can best be done with a reference manager.

Cross-links – i.e. links within a document – are important for scholarly
texts. It should be possible to link to section headers (e.g. the
beginning of the discussion section), figures and tables.

Math
----

Complicated math is probably best done in a different authoring
environment, but simple formulas, both inline $\sqrt2x$ and block elements 

>  ${\frac {d}{dx}}\arctan(\sin({x}^{2}))=-2\,{\frac {\cos({x}^{2})x}{-2+\left (\cos({x}^{2})\right )^{2}}}$

should be supported by scholarly markdown.

Comments
--------

Comments are important for multi-author documents and if reviewer
feedback should be included. Comments should be linked to a particular
part of a document to provide context, or attached at the end of a
document for general comments. It would also be helpful to “comment out”
parts of a document, e.g. to indicate parts that are incomplete and need
more work. Revisions of a markdown document are best handled using a
version control system such as git.

References
----------
