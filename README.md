# Program Booklet for Protocol Berg

Script to generate a rendered PDF file from the Pretalx sessions API.

### Install

Requires **Rulex** Ruby LaTeX parser and **Kramdown** Ruby Markdown parser.

```
gem install rulex kramdown
```

Also, install `texlive` on your system to be able to build the TeX documents.

### Run

```
curl -H "Authorization: Token $PRETALX_TOKEN" "https://cfp.protocol.berlin/api/events/protocol-berg-v2/submissions/?limit=250&offset=0" > ./sessions.json
```

Parse the sessions JSON to TeX:

```
rulex ./booklet.rex > ./booklet.tex
```

Render PDF from TeX:

```
pdflatex -interaction=nonstopmode -output-format=pdf ./booklet.tex
```

### Print

Print booklet in DIN A5.
