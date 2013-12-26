---
layout: post
title: "What Can Article Level Metrics Do for You?"
date: 2013-10-22
tags: [molecular biology, cancer]
bibliography: examples/example.bib
csl: examples/jats.csl
article:
  type: research-article
  publisher-id: PBIOLOGY-D-13-03338
  doi: 10.1371/journal.pbio.1001687
  elocation-id: e1001687
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
   corresp: yes
copyright:
  holder: Martin Fenner
  year: 2013
  text: "This is an open-access article distributed under the terms of the Creative Commons Attribution License, which permits unrestricted use, distribution, and reproduction in any medium, provided the original author and source are credited."
  type: open-access
  link: http://creativecommons.org/licenses/by/3.0/
---
*Article-level metrics (ALMs) provide a wide range of metrics about the
uptake of an individual journal article by the scientific community
after publication. They include citations, usage statistics, discussions
in online comments and social media, social bookmarking, and
recommendations. In this essay, we describe why article-level metrics
are an important extension of traditional citation-based journal metrics
and provide a number of example from ALM data collected for PLOS
Biology.*

> This is an open-access article distributed under the terms of the Creative Commons Attribution License, authored by me and [originally published Oct 22, 2013 in PLOS Biology](http://dx.doi.org/10.1371/journal.pbio.1001687).

The scientific impact of a particular piece of research is reflected in
how this work is taken up by the scientific community. The first
systematic approach that was used to assess impact, based on the
technology available at the time, was to track citations and aggregate
them by journal. This strategy is not only no longer necessary — since now
we can easily track citations for individual articles — but also, and more
importantly, journal-based metrics are now considered a poor performance
measure for individual articles [@Campbell2008; @Glanzel2013]. One major
problem with journal-based metrics is the variation in citations per
article, which means that a small percentage of articles can skew, and
are responsible for, the majority of the journal-based citation impact
factor, as shown by Campbell [-@Campbell2008] for the 2004
*Nature* Journal Impact Factor. **Figure 1** further
illustrates this point, showing the wide distribution of citation counts
between *PLOS Biology* research articles published in 2010. *PLOS
Biology* research articles published in 2010 have been cited a median 19
times to date in Scopus, but 10% of them have been cited 50 or more
times, and two articles [@Narendra:2010fw; @Dickson:2010ix] more than
300 times. *PLOS Biology* metrics are used as examples throughout this
essay, and the dataset is available in the supporting information (**Data
S1**). Similar data are available for an increasing
number of other publications and organizations.


```r
# code for figure 1: density plots for citation counts for PLOS Biology
# articles published in 2010

# load May 20, 2013 ALM report
alm <- read.csv("../data/alm_report_plos_biology_2013-05-20.csv", stringsAsFactors = FALSE)

# only look at research articles
alm <- subset(alm, alm$article_type == "Research Article")

# only look at papers published in 2010
alm$publication_date <- as.Date(alm$publication_date)
alm <- subset(alm, alm$publication_date > "2010-01-01" & alm$publication_date <=
    "2010-12-31")

# labels
colnames <- dimnames(alm)[[2]]
plos.color <- "#1ebd21"
plos.source <- "scopus"

plos.xlab <- "Scopus Citations"
plos.ylab <- "Probability"

quantile <- quantile(alm[, plos.source], c(0.1, 0.5, 0.9), na.rm = TRUE)

# plot the chart
opar <- par(mai = c(0.5, 0.75, 0.5, 0.5), omi = c(0.25, 0.1, 0.25, 0.1), mgp = c(3,
    0.5, 0.5), fg = "black", cex.main = 2, cex.lab = 1.5, col = plos.color,
    col.main = plos.color, col.lab = plos.color, xaxs = "i", yaxs = "i")

d <- density(alm[, plos.source], from = 0, to = 100)
d$x <- append(d$x, 0)
d$y <- append(d$y, 0)
plot(d, type = "n", main = NA, xlab = NA, ylab = NA, xlim = c(0, 100), frame.plot = FALSE)
polygon(d, col = plos.color, border = NA)
mtext(plos.xlab, side = 1, col = plos.color, cex = 1.25, outer = TRUE, adj = 1,
    at = 1)
mtext(plos.ylab, side = 2, col = plos.color, cex = 1.25, outer = TRUE, adj = 0,
    at = 1, las = 1)

par(opar)
```

![**Figure 1. Citation counts for PLOS Biology articles published in 2010.** Scopus citation counts plotted as a probability distribution for all 197 *PLOS Biology* research articles published in 2010. Data collected May 20, 2013. Median 19 citations; 10% of papers have at least 50 citations.](/images/2013-12-11_figure_1.svg)


Scientific impact is a multi-dimensional construct that can not be
adequately measured by any single indicator
[@Glanzel2013; @bollenEtal2009; @Schekman2013].
To this end, PLOS has collected and displayed a variety of metrics for
all its articles since 2009. The array of different categorised
article-level metrics (ALMs) used and provided by PLOS as of August 2013
are shown in **Figure 2**. In addition to citations
and usage statistics, i.e., how often an article has been viewed and
downloaded, PLOS also collects metrics about: how often an article has
been saved in online reference managers, such as Mendeley; how often an
article has been discussed in its comments section online, and also in
science blogs or in social media; and how often an article has been
recommended by other scientists. These additional metrics provide
valuable information that we would miss if we only consider citations.
Two important shortcomings of citation-based metrics are that (1) they
take years to accumulate and (2) citation analysis is not always the
best indicator of impact in more practical fields, such as clinical
medicine [@VanEck2013]. Usage statistics often better
reflect the impact of work in more practical fields, and they also
sometimes better highlight articles of general interest (for example,
the 2006 *PLOS Biology* article on the citation advantage of Open Access
articles [@Eysenbach2006], one of the 10 most-viewed
articles published in *PLOS Biology*).

![**Figure 2. Article-level metrics used by PLOS in August 2013 and their
categories.** Taken from [@Lin2013] with permission by the authors.](/images/2013-12-11_figure_2.png)

A bubble chart showing all 2010 *PLOS Biology* articles (**Figure
3**) gives a good overview of the year's views and
citations, plus it shows the influence that the article type (as
indicated by dot color) has on an article's performance as measured by
these metrics. The weekly *PLOS Biology* publication schedule is
reflected in this figure, with articles published on the same day
present in a vertical line. **Figure 3** also shows
that the two most highly cited 2010 *PLOS Biology* research articles are
also among the most viewed (indicated by the red arrows), but overall
there isn't a strong correlation between citations and views. The
most-viewed article published in 2010 in *PLOS Biology* is an essay on
Darwinian selection in robots [@Floreano2010]. Detailed
usage statistics also allow speculatulation about the different ways
that readers access and make use of published literature; some articles
are browsed or read online due to general interest while others that are
downloaded (and perhaps also printed) may reflect the reader's intention
to look at the data and results in detail and to return to the article
more than once.


```r
# code for figure 3: Bubblechart views vs. citations for PLOS Biology
# articles published in 2010.

# Load required libraries
library(plyr)

# load May 20, 2013 ALM report
alm <- read.csv("../data/alm_report_plos_biology_2013-05-20.csv", stringsAsFactors = FALSE,
    na.strings = c("0"))

# only look at papers published in 2010
alm$publication_date <- as.Date(alm$publication_date)
alm <- subset(alm, alm$publication_date > "2010-01-01" & alm$publication_date <=
    "2010-12-31")

# make sure counter values are numbers
alm$counter_html <- as.numeric(alm$counter_html)

# lump all papers together that are not research articles
reassignType <- function(x) if (x == "Research Article") 1 else 0
alm$article_group <- aaply(alm$article_type, 1, reassignType)

# calculate article age in months
alm$age_in_months <- (Sys.Date() - alm$publication_date)/365.25 * 12
start_age_in_months <- floor(as.numeric(Sys.Date() - as.Date(strptime("2010-12-31",
    format = "%Y-%m-%d")))/365.25 * 12)

# chart variables
x <- alm$age_in_months
y <- alm$counter
z <- alm$scopus

xlab <- "Age in Months"
ylab <- "Total Views"

labels <- alm$article_group
col.main <- "#1ebd21"
col <- "#666358"

# calculate bubble diameter
z <- sqrt(z/pi)

# calculate bubble color
getColor <- function(x) c("#c9c9c7", "#1ebd21")[x + 1]
colors <- aaply(labels, 1, getColor)

# plot the chart
opar <- par(mai = c(0.5, 0.75, 0.5, 0.5), omi = c(0.25, 0.1, 0.25, 0.1), mgp = c(3,
    0.5, 0.5), fg = "black", cex = 1, cex.main = 2, cex.lab = 1.5, col = "white",
    col.main = col.main, col.lab = col)

plot(x, y, type = "n", xlim = c(start_age_in_months, start_age_in_months + 13),
    ylim = c(0, 60000), xlab = NA, ylab = NA, las = 1)
symbols(x, y, circles = z, inches = exp(1.3)/15, bg = colors, xlim = c(start_age_in_months,
    start_age_in_months + 13), ylim = c(0, ymax), xlab = NA, ylab = NA, las = 1,
    add = TRUE)
mtext(xlab, side = 1, col = col.main, cex = 1.25, outer = TRUE, adj = 1, at = 1)
mtext(ylab, side = 2, col = col.main, cex = 1.25, outer = TRUE, adj = 0, at = 1,
    las = 1)

par(opar)
```

![**Figure 3. Views vs. citations for PLOS Biology articles published in 2010.** All 304 *PLOS Biology* articles published in 2010. Bubble size correlates with number of Scopus citations. Research articles are labeled green; all other articles are grey. Red arrows indicate the two most highly cited papers. Data collected May 20, 2013.](/images/2013-12-11_figure_3.svg)


When readers first see an interesting article, their response is often
to view or download it. By contrast, a citation may be one of the last
outcomes of their interest, occuring only about 1 in 300 times a PLOS
paper is viewed online. A lot of things happen in between these
potential responses, ranging from discussions in comments, social media,
and blogs, to bookmarking, to linking from websites. These activities
are usually subsumed under the term “altmetrics,” and their variety can
be overwhelming. Therefore, it helps to group them together into
categories, and several organizations, including PLOS, are using the
category labels of Viewed, Cited, Saved, Discussed, and Recommended
(**Figures 2 and 4**, see also [@Lin2013]).


```r
# code for figure 4: bar plot for Article-level metrics for PLOS Biology

# Load required libraries
library(reshape2)

# load May 20, 2013 ALM report
alm <- read.csv("../data/alm_report_plos_biology_2013-05-20.csv", stringsAsFactors = FALSE,
    na.strings = c(0, "0"))

# only look at research articles
alm <- subset(alm, alm$article_type == "Research Article")

# make sure columns are in the right format
alm$counter_html <- as.numeric(alm$counter_html)
alm$mendeley <- as.numeric(alm$mendeley)

# options
plos.color <- "#1ebd21"
plos.colors <- c("#a17f78", "#ad9a27", "#ad9a27", "#ad9a27", "#ad9a27", "#ad9a27",
    "#dcebdd", "#dcebdd", "#789aa1", "#789aa1", "#789aa1", "#304345", "#304345")

# use subset of columns
alm <- subset(alm, select = c("f1000", "wikipedia", "researchblogging", "comments",
    "facebook", "twitter", "citeulike", "mendeley", "pubmed", "crossref", "scopus",
    "pmc_html", "counter_html"))

# calculate percentage of values that are not missing (i.e. have a count of
# at least 1)
colSums <- colSums(!is.na(alm)) * 100/length(alm$counter_html)
exactSums <- sum(as.numeric(alm$pmc_html), na.rm = TRUE)

# plot the chart
opar <- par(mar = c(0.1, 7.25, 0.1, 0.1) + 0.1, omi = c(0.1, 0.25, 0.1, 0.1),
    col.main = plos.color)

plos.names <- c("F1000Prime", "Wikipedia", "Research Blogging", "PLOS Comments",
    "Facebook", "Twitter", "CiteULike", "Mendeley", "PubMed Citations", "CrossRef",
    "Scopus", "PMC HTML Views", "PLOS HTML Views")
y <- barplot(colSums, horiz = TRUE, col = plos.colors, border = NA, xlab = plos.names,
    xlim = c(0, 120), axes = FALSE, names.arg = plos.names, las = 1, adj = 0)
text(colSums + 6, y, labels = sprintf("%1.0f%%", colSums))

par(opar)
```

![**Figure 4. Article-level metrics for PLOS Biology.** Proportion of all 1,706 *PLOS Biology* research articles published up to May 20, 2013 mentioned by particular article-level metrics source. Colors indicate categories (Viewed, Cited, Saved, Discussed, Recommended), as used on the PLOS website.](/images/2013-12-11_figure_4.svg)


All *PLOS Biology* articles are viewed and downloaded, and almost all of
them (all research articles and nearly all front matter) will be cited
sooner or later. Almost all of them will also be bookmarked in online
reference managers, such as Mendeley, but the percentage of articles
that are discussed online is much smaller. Some of these percentages are
time dependent; the use of social media discussion platforms, such as
Twitter and Facebook for example, has increased in recent years (93% of
*PLOS Biology* research articles published since June 2012 have been
discussed on Twitter, and 63% mentioned on Facebook). These are the
locations where most of the online discussion around published articles
currently seems to take place; the percentage of papers with comments on
the PLOS website or that have science blog posts written about them is
much smaller. Not all of this online discussion is about research
articles, and perhaps, not surprisingly, the most-tweeted PLOS article
overall (with more than 1,100 tweets) is a *PLOS Biology* perspective on
the use of social media for scientists [@Bik2013].

Some metrics are not so much indicators of a broad online discussion,
but rather focus on highlighting articles of particular interest. For
example, science blogs allow a more detailed discussion of an article as
compared to comments or tweets, and journals themselves sometimes choose
to highlight a paper on their own blogs, allowing for a more digestible
explanation of the science for the non-expert reader
[@Fausto2012]. Coverage by other bloggers also serves
the same purpose; a good example of this is one recent post on the
OpenHelix Blog [@Video2012] that contains video footage
of the second author of a 2010 *PLOS Biology* article
[@Dalloul2010] discussing the turkey genome.

F1000Prime, a commercial service of recommendations by expert
scientists, was added to the PLOS Article-Level Metrics in August 2013.
We now highlight on the PLOS website when any articles have received at
least one recommendation within F1000Prime. We also monitor when an
article has been cited within the widely used modern-day online
encyclopedia, Wikipedia. A good example of the latter is the Tasmanian
devil Wikipedia page [@Tasmanian2013] that links to a
*PLOS Biology* research article published in 2010
[@Nilsson2010]. While a F1000Prime recommendation is a
strong endorsement from peer(s) in the scientific community, being
included in a Wikipedia page is akin to making it into a textbook about
the subject area and being read by a much wider audience that goes
beyond the scientific community.

*PLOS Biology* is the PLOS journal with the highest percentage of
articles recommended in F1000Prime and mentioned in Wikipedia, but there
is only partial overlap between the two groups of articles because they
focus on different audiences (**Figure 5**). These
recommendations and mentions in turn show correlations with other
metrics, but not simple ones; you can't assume, for example, that highly
cited articles are more likely to be recommended by F1000Prime, so it
will be interesting to monitor these trends now that we include this
information.


```r
# code for figure 5: Venn diagram F1000 vs. Wikipedia for PLOS Biology
# articles

# load required libraries
library("plyr")
library("VennDiagram")

# load May 20, 2013 ALM report
alm <- read.csv("../data/alm_report_plos_biology_2013-05-20.csv", stringsAsFactors = FALSE)

# only look at research articles
alm <- subset(alm, alm$article_type == "Research Article")

# group articles based on values in Wikipedia and F1000
reassignWikipedia <- function(x) if (x > 0) 1 else 0
alm$wikipedia_bin <- aaply(alm$wikipedia, 1, reassignWikipedia)
reassignF1000 <- function(x) if (x > 0) 2 else 0
alm$f1000_bin <- aaply(alm$f1000, 1, reassignF1000)
alm$article_group = alm$wikipedia_bin + alm$f1000_bin
reassignCombined <- function(x) if (x == 3) 1 else 0
alm$combined_bin <- aaply(alm$article_group, 1, reassignCombined)
reassignNo <- function(x) if (x == 0) 1 else 0
alm$no_bin <- aaply(alm$article_group, 1, reassignNo)

# remember to divide f1000_bin by 2, as this is the default value
summary <- colSums(subset(alm, select = c("wikipedia_bin", "f1000_bin", "combined_bin",
    "no_bin")), na.rm = TRUE)
rows <- nrow(alm)

# options
plos.colors <- c("#c9c9c7", "#0000ff", "#ff0000")

# plot the chart
opar <- par(mai = c(0.5, 0.75, 3.5, 0.5), omi = c(0.5, 0.5, 1.5, 0.5), mgp = c(3,
    0.5, 0.5), fg = "black", cex.main = 2, cex.lab = 1.5, col = plos.color,
    col.main = plos.color, col.lab = plos.color, xaxs = "i", yaxs = "i")

venn.plot <- draw.triple.venn(area1 = rows, area2 = summary[1], area3 = summary[2]/2,
    n12 = summary[1], n23 = summary[3], n13 = summary[2]/2, n123 = summary[3],
    euler.d = TRUE, scaled = TRUE, fill = plos.colors, cex = 2, fontfamily = rep("sans",
        7))

par(opar)
```

![**Figure 5. PLOS Biology articles: sites of recommendation and discussion.** Number of *PLOS Biology* research articles published up to May 20, 2013 that have been recommended by F1000Prime (red) or mentioned in Wikipedia (blue).](/images/2013-12-11_figure_5.svg)


With the increasing availability of ALM data, there comes a growing need
to provide tools that will allow the community to interrogate them. A
good first step for researchers, research administrators, and others
interested in looking at the metrics of a larger set of PLOS articles is
the recently launched ALM Reports tool [@ALM2013]. There
are also a growing number of service providers, including Altmetric.com
[@Altmetric2013], ImpactStory [@Impactstory2013], and Plum Analytics
[@Plum2013] that provide similar services for articles
from other publishers.

As article-level metrics become increasingly used by publishers,
funders, universities, and researchers, one of the major challenges to
overcome is ensuring that standards and best practices are widely
adopted and understood. The National Information Standards Organization
(NISO) was recently awarded a grant by the Alfred P. Sloan Foundation to
work on this [@NISO2013], and PLOS is actively involved
in this project. We look forward to further developing our article-level
metrics and to having them adopted by other publishers, which hopefully
will pave the way to their wide incorporation into research and
researcher assessments.

### Supporting Information

**[Data S1](http://dx.doi.org/10.1371/journal.pbio.1001687.s001).
Dataset of ALM for PLOS Biology articles used in the text, and
R scripts that were used to produce figures.** The data were collected
on May 20, 2013 and include all *PLOS Biology* articles published up to
that day. Data for F1000Prime were collected on August 15, 2013. All
charts were produced with R version 3.0.0.