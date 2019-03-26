; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@hugbox.org>

(define-transpiler-end generate-code
    backend-input          [(& *development?*
                               (format t "o~F"))
                            _]
    function-names         #'translate-function-names
    encapsulate-strings    #'encapsulate-strings
    count-tags             #'count-tags
    wrap-tags              #'wrap-tags
    codegen-expand         [expander-expand (codegen-expander) _]
    obfuscate              #'obfuscate
    convert-identifiers    #'convert-identifiers
    output-filter          #'concat-stringtree)

(define-transpiler-end backend-make-places
    make-framed-functions  #'make-framed-functions
    place-expand           #'place-expand
    place-assign           #'place-assign
    warn-unused            #'warn-unused)

(defun backend-prepare (x)
  (? (lambda-export?)
     (backend-make-places x)
	 (make-framed-functions x)))

(defun backend (x)
  (? (enabled-end? :backend)
     (@ [generate-code (backend-prepare (list _))] x)
     x))
