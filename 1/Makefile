defaults: my-git-cheat-sheet.1.pdf my-git-cheat-sheet.2.pdf

my-git-cheat-sheet.1.ps: my-git-cheat-sheet.1.txt Makefile
	enscript -o- --landscape --font=Courier8 --no-header $< >$@.tmp
	mv $@.tmp $@
my-git-cheat-sheet.2.ps: my-git-cheat-sheet.2.txt Makefile
	enscript -o- --no-header $< >$@.tmp
	mv $@.tmp $@
%.pdf: %.ps
	ps2pdf $< $@.tmp.pdf
	mv $@.tmp.pdf $@
