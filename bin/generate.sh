#!/usr/bin/env bash

set +e

rulex ./booklet.rex > ./booklet.tex

pdflatex -interaction=nonstopmode -output-format=pdf ./booklet.tex
pdflatex -interaction=nonstopmode -output-format=pdf ./booklet.tex
