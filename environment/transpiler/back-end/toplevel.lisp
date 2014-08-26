;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun transpiler-postprocess (&rest x)
  (apply (transpiler-postprocessor *transpiler*) x))

(transpiler-pass generate-code ()
    function-names         [? (transpiler-function-name-prefix *transpiler*)
                              (translate-function-names (transpiler-global-funinfo *transpiler*) _)
                              _]
    encapsulate-strings    [? (transpiler-encapsulate-strings? *transpiler*)
                              (transpiler-encapsulate-strings _)
                              _]
    count-tags             [(& (transpiler-count-tags? *transpiler*)
                               (count-tags _))
                            _]
    wrap-tags              #'wrap-tags
    codegen-expand         [expander-expand (transpiler-codegen-expander *transpiler*) _]
    obfuscate              [? (transpiler-make-text? *transpiler*)
                              (obfuscate _)
                              _]
    convert-identifiers    [? (transpiler-make-text? *transpiler*)
                              (convert-identifiers _)
                              _]
    postprocess            #'transpiler-postprocess)

(transpiler-pass backend-make-places ()
    make-framed-functions  #'make-framed-functions
    place-expand           #'place-expand
    place-assign           #'place-assign
    warn-unused            [? (transpiler-warn-on-unused-symbols? *transpiler*)
                              (warn-unused _)
                              _])

(defun backend-prepare (x)
  (? (transpiler-lambda-export? *transpiler*)
     (backend-make-places x)
	 (make-framed-functions x)))

(defun backend-0 (x)
  (generate-code (backend-prepare (list x))))

(defun backend (x)
  (& x
     (transpiler-postprocess (filter #'backend-0 x))))
