# Makefile for theses using acadiathesis.sty or acadiahonthesis.sty

COMPILE = xelatex

FILES = *.tex beamerthemehsrm.sty

AUX_FILES = *.aux *.toc *.nav *.snm *.bbl *.blg *.loa *.lof *.log *.lol *.lot *.out

PAPER = scruffy

$(PAPER).pdf: $(FILES)
	$(COMPILE) $(PAPER) || true
	$(COMPILE) $(PAPER)

all: $(PAPER).pdf

clean:
	rm -f $(AUX_FILES) $(PAPER).pdf
