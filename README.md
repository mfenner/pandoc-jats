pandoc-jats
===========

A Lua [custom writer for Pandoc](http://johnmacfarlane.net/pandoc/README.html#custom-writers) generating **JATS XML** - specifically [Journal Publishing Tag Library NISO JATS Version 1.0](http://jats.nlm.nih.gov/publishing/tag-library/1.0/index.html).

### Installation
Just download the file `JATS.lua` and put it in a convenient location. Pandoc includes a lua interpreter, so lua need not be installed separately. You need at least Pandoc version 1.13, released August 2014 (this release adds `--template` support for custom writers).

### Usage
To convert the markdown file `example1.md` into the JATS XML file `example1.xml`, use the following command:

```
pandoc examples/example1.md --filter pandoc-citeproc -t jats.lua -o example1.xml --template=default.jats --bibliography=examples/example.bib --csl=jats.csl
```

### Template
`pandoc-jats` uses the template `default.jats` - the template uses the same format as other [Pandoc templates](https://github.com/jgm/pandoc-templates) (e.g. if/end conditions, for/end loops, and a dot can be used to select a field of a variable that takes an object),
but is more complex because of the extensive metadata in JATS. Templates are parsed by Pandoc, not the custom Lua writer.

```
<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE article PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.0 20120330//EN"
                  "JATS-journalpublishing1.dtd">
$if(article.type)$
<article xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xlink="http://www.w3.org/1999/xlink" dtd-version="1.0" article-type="$article.type$">
$else$
<article xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xlink="http://www.w3.org/1999/xlink" dtd-version="1.0" article-type="other">
$endif$
<front>
<journal-meta>
$if(journal.publisher-id)$
<journal-id journal-id-type="publisher-id">$journal.publisher-id$</journal-id>
$endif$
$if(journal.nlm-ta)$
<journal-id journal-id-type="nlm-ta">$journal.nlm-ta$</journal-id>
$endif$
$if(journal.pmc)$
<journal-id journal-id-type="pmc">$journal.pmc$</journal-id>
$endif$
<journal-title-group>
$if(journal.title)$
<journal-title>$journal.title$</journal-title>
$endif$
$if(journal.abbrev-title)$
<abbrev-journal-title>$journal.abbrev-title$</abbrev-journal-title>
$endif$
</journal-title-group>
$if(journal.pissn)$
<issn pub-type="ppub">$journal.pissn$</issn>
$endif$
$if(journal.eissn)$
<issn pub-type="epub">$journal.eissn$</issn>
$endif$
<publisher>
<publisher-name>$journal.publisher-name$</publisher-name>
$if(journal.publisher-loc)$
<publisher-loc>$journal.publisher-loc$</publisher-loc>
$endif$
</publisher>
</journal-meta>
<article-meta>
$if(article.publisher-id)$
<article-id pub-id-type="publisher-id">$article.publisher-id$</article-id>
$endif$
$if(article.doi)$
<article-id pub-id-type="doi">$article.doi$</article-id>
$endif$
$if(article.pmid)$
<article-id pub-id-type="pmid">$article.pmid$</article-id>
$endif$
$if(article.pmcid)$
<article-id pub-id-type="pmcid">$article.pmcid$</article-id>
$endif$
$if(article.art-access-id)$
<article-id pub-id-type="art-access-id">$article.art-access-id$</article-id>
$endif$
$if(article.heading)$
<article-categories>
<subj-group subj-group-type="heading">
<subject>$article.heading$</subject>
</subj-group>
$if(article.categories)$
<subj-group subj-group-type="categories">
$for(article.categories)$
<subject>$article.categories$</subject>
$endfor$
</subj-group>
$endif$
</article-categories>
$endif$
$if(title)$
<title-group>
<article-title>$title$</article-title>
</title-group>
$endif$
$if(author)$
<contrib-group>
$for(author)$
<contrib contrib-type="author">
$if(author.orcid)$
<contrib-id contrib-id-type="orcid">$author.orcid$</contrib-id>
$endif$
<name>
$if(author.surname)$
<surname>$author.surname$</surname>
<given-names>$author.given-names$</given-names>
$else$
<string-name>$author$</string-name>
$endif$
</name>
$if(author.email)$
<email>$author.email$</email>
$endif$
$if(author.aff-id)$
<xref ref-type="aff" rid="aff-$contrib.aff-id$"/>
$endif$
$if(author.cor-id)$
<xref ref-type="corresp" rid="cor-$author.cor-id$"><sup>*</sup></xref>
$endif$
</contrib>
$endfor$
</contrib-group>
$endif$
$if(article.author-notes)$
<author-notes>
$if(article.author-notes.corresp)$
$for(article.author-notes.corresp)$
<corresp id="cor-$article.author-notes.corresp.id$">* E-mail: <email>$article.author-notes.corresp.email$</email></corresp>
$endfor$
$endif$
$if(article.author-notes.conflict)$
<fn fn-type="conflict"><p>$article.author-notes.conflict$</p></fn>
$endif$
$if(article.author-notes.con)$
<fn fn-type="con"><p>$article.author-notes.con$</p></fn>
$endif$
</author-notes>
$endif$
$if(date)$
$if(date.iso-8601)$
<pub-date pub-type="epub" iso-8601-date="$date.iso-8601$">
$else$
<pub-date pub-type="epub">
$endif$
$if(date.day)$
<day>$pub-date.day$</day>
$endif$
$if(date.month)$
<month>$pub-date.month$</month>
$endif$
$if(date.year)$
<year>$pub-date.year$</year>
$else$
<string-date>$date$</string-date>
$endif$
</pub-date>
$endif$
$if(article.volume)$
<volume>$article.volume$</volume>
$endif$
$if(article.issue)$
<issue>$article.issue$</issue>
$endif$
$if(article.fpage)$
<fpage>$article.fpage$</fpage>
$endif$
$if(article.lpage)$
<lpage>$article.lpage$</lpage>
$endif$
$if(article.elocation-id)$
<elocation-id>$article.elocation-id$</elocation-id>
$endif$
$if(history)$
<history>
</history>
$endif$
$if(copyright)$
<permissions>
$if(copyright.statement)$
<copyright-statement>$copyright.statement$</copyright-statement>
$endif$
$if(copyright.year)$
<copyright-year>$copyright.year$</copyright-year>
$endif$
$if(copyright.holder)$
<copyright-holder>$copyright.holder$</copyright-holder>
$endif$
$if(copyright.text)$
<license license-type="$copyright.type$" xlink:href="$copyright.link$">
<license-p>$copyright.text$</license-p>
</license>
</permissions>
$endif$
$endif$
$if(tags)$
<kwd-group kwd-group-type="author">
$for(tags)$
<kwd>$tags$</kwd>
$endfor$
</kwd-group>
$endif$
$if(article.funding-statement)$
<funding-group>
<funding-statement>$article.funding-statement$</funding-statement>
</funding-group>
$endif$
</article-meta>
$if(notes)$
<notes>$notes$</notes>
$endif$
</front>
$body$
</article>
```

### Citation Style (CSL)
`pandoc-jats` uses the `jats.csl` citation style that is included. This style generates XML in JATS format, which is an interim solution as CSL is not really intended to generate XML.

### Metadata
The metadata required for JATS can be stored in a YAML metadata block (new in Pandoc 1.12, the same format is also used by the Jekyll static blog generator. An example [from a recent blog post](http://blog.martinfenner.org/2013/12/11/what-can-article-level-metrics-do-for-you/) is below:

```
---
layout: post
title: "What Can Article Level Metrics Do for You?"
date: 2013-10-22
tags: [example, markdown, article-level metrics, reproducibility]
bibliography: examples/example.bib
csl: examples/jats.csl
article:
  type: research-article
  publisher-id: PBIOLOGY-D-13-03338
  doi: 10.1371/journal.pbio.1001687
  heading: Essay
journal:
  publisher-id: plos
  publisher-name: Public Library of Science
  publisher-loc: San Francisco, USA
  nlm-ta: PLoS Biol
  pmc: plosbiol
  title: PLoS Biology
  eissn: 1545-7885
  pissn: 1544-9173
author:
 - surname: Fenner
   given-names: Martin
   orcid: http://orcid.org/0000-0003-1419-2405
   email: mfenner@plos.org
   corresp: true
copyright:
  holder: Martin Fenner
  year: 2013
  text: "This is an open-access article distributed under the terms of the Creative Commons Attribution License, which permits unrestricted use, distribution, and reproduction in any medium, provided the original author and source are credited."
  type: open-access
  link: http://creativecommons.org/licenses/by/3.0/
---
```

The `article` and `journal` sections correspond to `<article-meta>` and `<journal-meta>` in JATS. The standard Pandoc metadata `title`, `author` and `date` are supported.

### Validation
The JATS XML should be validated, for example with the excellent [jats-conversion](https://github.com/PeerJ/jats-conversion) tools written by Alf Eaton.

### To Do
* supported for latest JATS version (1.1d3 in April 2015)
* parsing for references in Lua instead of using a CSL style
* more testing

### Feedback
This tool needs extensive testing with as many markdown documents as possible. Please open an issue in the [Issue Tracker](https://github.com/mfenner/pandoc-jats/issues) if you find a conversion problem.

### Testing

You'll need `busted` and `inspect` to run tests (you might need to install `luarocks` first):

```
luarocks install busted
luarocks install inspect
```

Then run all tests from the root directory (the same directory as `jats.lua`):

```
busted
```

The tests in `spec/input_spec.lua` are generic and can be reused for other custom Lua writers. They currently test whether all functions called by Pandoc exist. To run these tests against the `sample.lua` custom writer included with Pandoc, do `busted spec/sample_spec.lua`.

### License
© 2013-2015 Martin Fenner. Released under the [GPL](http://www.gnu.org/copyleft/gpl.html), version 2 or greater. See LICENSE for more info.
