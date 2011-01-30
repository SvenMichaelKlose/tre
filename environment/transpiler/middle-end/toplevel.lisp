;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun transpiler-expression-expand (tr x)
  (expression-expand (transpiler-expex tr) x))

;; In this pass
;; - Nested expressions are sequentialized.
;; - No more %VM-SCOPE forms.
;; - Keywords are quoted.
;; - Named functions get a special form if desired.
;; - Peephole-optimisations are performed.
;; - Tail-calls are resolved.
;; - Unused places are removed from functions.
;; - Continuation-passing-style transformations are performed.
;; - FUNINFOs are updated with number of jump tags in function.
(transpiler-pass transpiler-expand-compose (tr)
    print-dot (fn (princ #\.)
		          (force-output)
		          _)
    update-funinfo #'transpiler-update-funinfo
    opt-peephole #'opt-peephole
;    middleend-graph #'middleend-graph
    cps (fn ? (transpiler-continuation-passing-style? tr)
              (cps _)
              _)
    opt-remove-unused-places #'opt-places-remove-unused
    opt-find-unused-places #'opt-places-find-used
    opt-peephole #'opt-peephole
    opt-tailcall #'opt-tailcall
    opt-peephole #'opt-peephole
    make-named-functions (fn transpiler-make-named-functions tr _)
    quote-keywords #'transpiler-quote-keywords
    expression-expand (fn transpiler-expression-expand tr _))

(defun transpiler-middleend-2 (tr x)
  (remove-if #'not
		     (funcall (transpiler-expand-compose tr) x)))
