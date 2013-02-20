;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun transpiler-expression-expand (tr x)
  (expression-expand (transpiler-expex tr) x))

;; After this pass
;; - Functions are assigned run-time argument definitions
;; - VM-SCOPEs are removed. All code is flat with jump tags.
;; - Peephole optimisations were performed.
;; - FUNINFOs were updated with number of jump tags in function.
;; - FUNCTION expression contain the names of top-level functions.
(transpiler-pass transpiler-middleend-0 (tr)
    print-dot                [(& *show-transpiler-progress?* (princ #\.) (force-output))
                              _]
    update-funinfo           #'transpiler-update-funinfo
    opt-remove-unused-places #'opt-places-remove-unused
    opt-find-unused-places   #'opt-places-find-used
;    middleend-graph          [(middleend-graph _)
;                              (identity _)]
;    cps                      [? (in-cps-mode?)
;                                (cps _)
;                                _]
    opt-peephole             #'opt-peephole
    opt-tailcall             #'opt-tailcall
    opt-peephole             #'opt-peephole
    link-funinfos            #'link-funinfos
    make-named-functions     [transpiler-make-named-functions tr _]
    quote-keywords           #'transpiler-quote-keywords
    inject-debugging         [? (transpiler-inject-debugging? tr)
                                (inject-debugging _)
                                _]
    expression-expand        [with-temporary *expex-warn?* nil
                               (transpiler-expression-expand tr _)]
    make-packages            #'make-packages)

(defun transpiler-middleend (tr x)
  (mapcan [transpiler-middleend-0 tr (list _)] x))
