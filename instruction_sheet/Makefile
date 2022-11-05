README.docx: README.tex
    pandoc -flatex -tdocx --data-dir=./pandoc -oREADME.docx README.tex

README.tex: README.md
    pandoc -fmarkdown -tlatex -oREADME.tex README.md
