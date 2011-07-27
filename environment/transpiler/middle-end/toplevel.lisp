;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun transpiler-expression-expand (tr x)
  (expression-expand (transpiler-expex tr) x))

;; After this pass
;; - Functions are assigned run-time argument definitions
;; - VM-SCOPEs are removed. All code is flat with jump tags.
;; - Peephole-optimisations were performed.
;; - FUNINFOs were updated with number of jump tags in function.
;; - FUNCTION expression contain the names of top-level functions.
(transpiler-pass transpiler-expand-compose (tr)
    print-dot (fn (princ #\.)
		          (force-output)
		          _)
    update-funinfo #'transpiler-update-funinfo
    opt-remove-unused-places #'opt-places-remove-unused
    opt-find-unused-places #'opt-places-find-used
;    middleend-graph #'middleend-graph
    cps (fn ? (in-cps-mode?)
              (cps _)
              _)
    opt-peephole #'opt-peephole
    opt-tailcall #'opt-tailcall
    opt-peephole #'opt-peephole
    make-named-functions (fn transpiler-make-named-functions tr _)
    quote-keywords #'transpiler-quote-keywords
    expression-expand (fn with-temporary *expex-warn?* nil
                           (transpiler-expression-expand tr _)))

(defun transpiler-middleend-2 (tr x)
  (remove-if #'not (funcall (transpiler-expand-compose tr) x)))
