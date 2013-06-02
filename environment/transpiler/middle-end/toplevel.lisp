;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun transpiler-expression-expand (tr x)
  (expression-expand (transpiler-expex tr) x))

(transpiler-pass transpiler-middleend-0 (tr)
    make-packages            #'make-packages
    expression-expand        [with-temporary *expex-warn?* nil
                               (transpiler-expression-expand tr _)]
    inject-debugging         [? (transpiler-inject-debugging? tr)
                                (inject-debugging _)
                                _]
    quote-keywords           #'transpiler-quote-keywords
    make-named-functions     [transpiler-make-named-functions tr _]
    link-funinfos            #'link-funinfos
    opt-peephole             #'opt-peephole
    opt-tailcall             #'opt-tailcall
    opt-peephole             #'opt-peephole
;    cps                      [? (in-cps-mode?)
;                                (cps _)
;                                _]
;    middleend-graph          [(middleend-graph _)
;                              (identity _)]
    opt-find-unused-places   #'opt-places-find-used
    opt-remove-unused-places #'opt-places-remove-unused
    update-funinfo           #'transpiler-update-funinfo
    print-dot                [(& *show-transpiler-progress?* (princ #\.) (force-output))
                              _])

(defun transpiler-middleend (tr x)
  (mapcan [transpiler-middleend-0 tr (list _)] x))
