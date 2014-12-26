; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun transpiler-postprocess (&rest x)
  (apply (transpiler-postprocessor) x))

(transpiler-pass generate-code ()
    print-o                [(& *development?*
                               (format t "o~F"))
                            _]
    function-names         [? (function-name-prefix)
                              (translate-function-names (global-funinfo) _)
                              _]
    encapsulate-strings    [? (encapsulate-strings?)
                              (transpiler-encapsulate-strings _)
                              _]
    count-tags             [(& (count-tags?)
                               (count-tags _))
                            _]
    wrap-tags              #'wrap-tags
    codegen-expand         [expander-expand (codegen-expander) _]
    obfuscate              [? (make-text?)
                              (obfuscate _)
                              _]
    convert-identifiers    [? (make-text?)
                              (convert-identifiers _)
                              _]
    postprocess            #'transpiler-postprocess)

(transpiler-pass backend-make-places ()
    make-framed-functions  #'make-framed-functions
    place-expand           #'place-expand
    place-assign           #'place-assign
    warn-unused            [? (warn-on-unused-symbols?)
                              (warn-unused _)
                              _])

(defun backend-prepare (x)
  (? (lambda-export?)
     (backend-make-places x)
	 (make-framed-functions x)))

(defun backend-0 (x)
  (generate-code (backend-prepare (list x))))

(defun backend (x)
  (& x
     (transpiler-postprocess (filter #'backend-0 x))))
