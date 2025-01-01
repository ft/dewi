MAN = dewi.1 dewifile.5 dewi.7
PDF = dewiprogram.pdf dewifile.pdf dewimanual.pdf
HTML = dewiprogram.html dewifile.html dewimanual.html

COMMONOPTIONS = --embed-resources --standalone --number-sections --toc

TEX_META = -V date='\today' --highlight-style=monochrome
HTML_META = -c manual.css --highlight-style=monochrome

all: man html pdf
man: $(MAN)
pdf: $(PDF)
html: $(HTML)

dewi.1: dewi_1.mdwn
	pandoc -t man $(COMMONOPTIONS) -o $@ dewi_1.mdwn
dewiprogram.pdf: dewi_1.mdwn
	pandoc --template template.latex $(COMMONOPTIONS) $(TEX_META) -o $@ dewi_1.mdwn
dewiprogram.html: dewi_1.mdwn
	pandoc -t html5 $(HTML_META) $(COMMONOPTIONS) -o $@ dewi_1.mdwn

dewifile.5: dewifile_5.mdwn
	pandoc -t man $(COMMONOPTIONS) -o $@ dewifile_5.mdwn
dewifile.pdf: dewifile_5.mdwn
	pandoc --template template.latex $(COMMONOPTIONS) $(TEX_META) -o $@ dewifile_5.mdwn
dewifile.html: dewifile_5.mdwn
	pandoc -t html5 $(HTML_META) $(COMMONOPTIONS) -o $@ dewifile_5.mdwn

dewi.7: dewi_7.mdwn
	pandoc -t man $(COMMONOPTIONS) -o $@ dewi_7.mdwn
dewimanual.pdf: dewi_7.mdwn
	pandoc --template template.latex $(COMMONOPTIONS) $(TEX_META) -o $@ dewi_7.mdwn
dewimanual.html: dewi_7.mdwn
	pandoc -t html5 $(HTML_META) $(COMMONOPTIONS) -o $@ dewi_7.mdwn

clean:
	rm -f $(HTML) $(PDF) $(MAN) *~

.PHONY: all man html pdf clean
