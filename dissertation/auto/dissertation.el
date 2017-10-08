(TeX-add-style-hook
 "dissertation"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("babel" "UKenglish") ("isodate" "UKenglish") ("biblatex" "backend=bibtex")))
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art10"
    "babel"
    "isodate"
    "biblatex")
   (LaTeX-add-bibliographies
    "references.bib"))
 :latex)

