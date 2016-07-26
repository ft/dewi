MAN = dewi.1 dewifile.5 dewi.7
PDF = dewiprogram.pdf dewifile.pdf dewimanual.pdf
HTML = dewiprogram.html dewifile.html dewimanual.html

COMMONOPTIONS = --self-contained --number-sections --normalize --smart --toc

TEX_META = -V date='\today' --highlight-style=monochrome
HTML_META = -c manual.css

DEWI1_TEX_META = -V author="Frank Terbeck"
DEWI1_TEX_META += -V title="dewi(1) Manual"
DEWI1_HTML_META = $(DEWI1_TEX_META) --highlight-style=monochrome
DEWI1_MAN_META = -V title="dewi" -V section="1" -V date="Jul, 2016"

DEWI7_TEX_META = -V author="Frank Terbeck"
DEWI7_TEX_META += -V title="dewi(7) Manual"
DEWI7_HTML_META = $(DEWI7_TEX_META) --highlight-style=monochrome
DEWI7_MAN_META = -V title="dewi" -V section="7" -V date="Jul, 2016"

RUNTESTS_TEX_META = -V author="Frank Terbeck"
RUNTESTS_TEX_META += -V title="dewifile(5) Manual"
RUNTESTS_HTML_META = $(RUNTESTS_TEX_META) --highlight-style=monochrome
RUNTESTS_MAN_META = -V title="dewifile" -V section="5" -V date="Jul, 2016"

all: man html pdf
man: $(MAN)
pdf: $(PDF)
html: $(HTML)

dewi.1: dewi_1.mdwn
	pandoc -t man $(COMMONOPTIONS) $(DEWI1_MAN_META) -o $@ dewi_1.mdwn
dewiprogram.pdf: dewi_1.mdwn
	pandoc --template template.latex $(COMMONOPTIONS) $(TEX_META) $(DEWI1_TEX_META) -o $@ dewi_1.mdwn
dewiprogram.html: dewi_1.mdwn
	pandoc -t html5 $(HTML_META) $(COMMONOPTIONS) $(DEWI1_HTML_META) -o $@ dewi_1.mdwn

dewifile.5: dewifile_5.mdwn
	pandoc -t man $(COMMONOPTIONS) $(RUNTESTS_MAN_META) -o $@ dewifile_5.mdwn
dewifile.pdf: dewifile_5.mdwn
	pandoc --template template.latex $(COMMONOPTIONS) $(TEX_META) $(RUNTESTS_TEX_META) -o $@ dewifile_5.mdwn
dewifile.html: dewifile_5.mdwn
	pandoc -t html5 $(HTML_META) $(COMMONOPTIONS) $(RUNTESTS_HTML_META) -o $@ dewifile_5.mdwn

dewi.7: dewi_7.mdwn
	pandoc -t man $(COMMONOPTIONS) $(DEWI7_MAN_META) -o $@ dewi_7.mdwn
dewimanual.pdf: dewi_7.mdwn
	pandoc --template template.latex $(COMMONOPTIONS) $(TEX_META) $(DEWI7_TEX_META) -o $@ dewi_7.mdwn
dewimanual.html: dewi_7.mdwn
	pandoc -t html5 $(HTML_META) $(COMMONOPTIONS) $(DEWI7_HTML_META) -o $@ dewi_7.mdwn

clean:
	rm -f $(HTML) $(PDF) $(MAN) *~

.PHONY: all man html pdf clean
