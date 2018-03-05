# makefile para a compilacao do documento

export TEXINPUTS := ./vendor:$(TEXINPUTS)
export BSTINPUTS := ./vendor:$(BSTINPUT)

BASE_NAME      := main
BUILD_DIR := build
PDF_NAME = mastersAthosRibeiro.pdf

LATEX          := pdflatex
#LATEX          := lualatex
#LATEX          := xelatex

# Ativando esta opcao, nao e preciso chamar "$(MAKEINDEX) $(BASENAME).idx"
# mais abaixo. Ela nao esta habilitada por padrao porque pode acarretar
# problemas de seguranca
#OPTS           := --shell-escape
OPTS := -halt-on-error -aux-directory=$(BUILD_DIR) -output-directory=$(BUILD_DIR)

#BIBTEX         := bibtex
BIBTEX         := biber

# "-C utf8" e um truque para contornar este bug, que existe em outras
# distribuicoes tambem:
# https://bugs.launchpad.net/ubuntu/+source/xindy/+bug/1735439
#MAKEINDEX      := makeindex
MAKEINDEX      := texindy -C utf8 -M vendor/hyperxindy.xdy

###############################################################################

STYLEFILES       := $(wildcard vendor/*)
OTHERTEXFILES  := $(wildcard *.tex) $(STYLEFILES)
BIBFILES       := $(wildcard *.bib)
IMGFILES       := $(wildcard figures/*)

all: pdf
default: pdf
pdf: $(BASE_NAME).pdf

$(BASE_NAME).pdf: $(BASE_NAME).tex $(BIBFILES) $(IMGFILES) $(OTHERTEXFILES)
	mkdir -p $(BUILD_DIR)
	$(LATEX) $(OPTS) $(BASE_NAME)
	$(BIBTEX) $(BUILD_DIR)/$(BASE_NAME)
	@while grep -Eq 'Rerun to get .* right|Please rerun .*[tT]e[xX]|Table widths have changed. Rerun LaTeX' build/*.log; \
                do $(MAKEINDEX) $(BUILD_DIR)/$(BASE_NAME).idx; \
		$(LATEX) $(OPTS) $(BASE_NAME); done
	cp $(BUILD_DIR)/$(BASE_NAME).pdf $(PDF_NAME)
	gnome-open $(PDF_NAME)

clean:
	-rm  -rf missfont.log *.bbl *.aux *.log *.toc *.cb *.out \
		*.blg *.brf *.ilg *.ind *.lof *.lot *.idx *.bcf \
		$(BASE_NAME).run.xml $(BASE_NAME).dvi \
		$(BASE_NAME).ps $(BASE_NAME).pdf $(BUILD_DIR) \
		$(PDF_NAME)

check:
	find chapters -regex '.*\.tex' -exec aspell --add-extra-dicts=./.aspell.pws -t -l en -c {} \;
	find . -regex '.*\.bak' -exec rm -f {} \;

.PHONY: all clean check
