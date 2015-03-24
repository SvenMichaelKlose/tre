; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@hugbox.org>

(transpiler-pass generate-code
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
    postprocess            [apply (postprocessor) _])

(transpiler-pass backend-make-places
    make-framed-functions  #'make-framed-functions
    place-expand           #'place-expand
    place-assign           #'place-assign
    warn-unused            #'warn-unused)

(defun backend-prepare (x)
  (? (lambda-export?)
     (backend-make-places x)
	 (make-framed-functions x)))

(defun backend-0 (x)
  (? (frontend-only?)
     x
     (generate-code (backend-prepare (list x)))))

(defun backend (x)
  (& x (@ #'backend-0 x)))
