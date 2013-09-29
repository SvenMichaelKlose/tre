;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun transpiler-concat-text (tr &rest x)
  (apply (transpiler-code-concatenator tr) x))

(transpiler-pass transpiler-generate-code (tr)
    function-names      [? (transpiler-function-name-prefix tr)
                           (translate-function-names (transpiler-global-funinfo *transpiler*) _)
                           _]
    encapsulate-strings [? (transpiler-encapsulate-strings? tr)
                           (transpiler-encapsulate-strings _)
                           _]
    count-tags          [(& (transpiler-count-tags? tr)
                            (count-tags _))
                         _]
    wrap-tags           #'wrap-tags
    codegen-expand      [expander-expand (transpiler-codegen-expander tr) _]
    obfuscate           [? (transpiler-make-text? tr)
                           (obfuscate _)
                           _]
    to-string           [? (transpiler-make-text? tr)
                           (transpiler-to-string tr _)
                           _]
    concat-stringtree   [transpiler-concat-text tr _])

(transpiler-pass transpiler-backend-make-places (tr)
    make-framed-functions  #'make-framed-functions
    place-expand           #'place-expand
    place-assign           #'place-assign
    warn-unused            [? (transpiler-warn-on-unused-symbols? tr)
                              (warn-unused _)
                              _])

(defun transpiler-backend-prepare (tr x)
  (? (transpiler-lambda-export? tr)
     (transpiler-backend-make-places tr x)
	 (make-framed-functions x)))

(defun transpiler-backend-0 (tr x)
  (transpiler-concat-text tr (transpiler-generate-code tr (transpiler-backend-prepare tr (list x)))))

(defun transpiler-backend (tr x)
  (& x
     (transpiler-concat-text tr (filter [transpiler-backend-0 tr _] x))))
