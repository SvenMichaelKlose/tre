; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@hugbox.org>

(def-pass-fun pass-function-names x
  (? (function-name-prefix)
     (translate-function-names (global-funinfo) x)
     x))

(def-pass-fun pass-encapsulate-strings x
  (? (encapsulate-strings?)
     (transpiler-encapsulate-strings x)
     x))

(def-pass-fun pass-count-tags x
  (& (count-tags?)
     (count-tags x))
  x)

(def-pass-fun pass-codegen-expand x
  (expander-expand (codegen-expander) x))

(def-pass-fun pass-obfuscate x
  (? (make-text?)
     (obfuscate x)
     x))

(def-pass-fun pass-convert-identifiers x
  (? (make-text?)
     (convert-identifiers x)
     x))

(def-pass-fun transpiler-postprocess x
  (apply (postprocessor) (list x)))

(def-pas-fun pass-warn-unused x
  (? (warn-on-unused-symbols?)
     (warn-unused x)
     x))

(transpiler-pass generate-code ()
    print-o                [(& *development?*
                               (format t "o~F"))
                            _]
    function-names         #'pass-function-names
    encapsulate-strings    #'pass-encapsulate-strings
    count-tags             #'pass-count-tags
    wrap-tags              #'wrap-tags
    codegen-expand         #'pass-codegen-expand
    obfuscate              #'pass-obfuscate
    convert-identifiers    #'pass-convert-identifiers
    postprocess            #'transpiler-postprocess)

(transpiler-pass backend-make-places ()
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
  (& x (filter #'backend-0 x)))
