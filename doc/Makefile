PAGES = dewi.1 dewi.7 dewifile.5

.SUFFIXES:
.SUFFIXES: .1 .5 .7 .t2t

all: $(PAGES)
clean:
	rm -f *.1 *.5 *.7

dewi.7: dewiseven.t2t
	txt2tags --target man -o- $< | sed -e '/^$$/d' -e 's/^\\e$$//' > $@

.t2t.1:
	txt2tags --target man -o- $< | sed -e '/^$$/d' -e 's/^\\e$$//' > $@

.t2t.5:
	txt2tags --target man -o- $< | sed -e '/^$$/d' -e 's/^\\e$$//' > $@

.t2t.7:
	txt2tags --target man -o- $< | sed -e '/^$$/d' -e 's/^\\e$$//' > $@

.PHONY: all clean
