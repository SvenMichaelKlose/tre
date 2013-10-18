;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun transpiler-concat-text (&rest x)
  (apply (transpiler-code-concatenator *transpiler*) x))

(transpiler-pass generate-code ()
    function-names      [? (transpiler-function-name-prefix *transpiler*)
                           (translate-function-names (transpiler-global-funinfo *transpiler*) _)
                           _]
    encapsulate-strings [? (transpiler-encapsulate-strings? *transpiler*)
                           (transpiler-encapsulate-strings _)
                           _]
    count-tags          [(& (transpiler-count-tags? *transpiler*)
                            (count-tags _))
                         _]
    wrap-tags           #'wrap-tags
    codegen-expand      [expander-expand (transpiler-codegen-expander *transpiler*) _]
    obfuscate           [? (transpiler-make-text? *transpiler*)
                           (obfuscate _)
                           _]
    to-string           [? (transpiler-make-text? *transpiler*)
                           (transpiler-to-string _)
                           _]
    concat-stringtree   #'transpiler-concat-text)

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
  (transpiler-concat-text (generate-code (backend-prepare (list x)))))

(defun backend (x)
  (& x
     (transpiler-concat-text (filter #'backend-0 x))))
