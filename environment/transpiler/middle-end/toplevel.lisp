;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun transpiler-expression-expand (tr x)
  (expression-expand (transpiler-expex tr) x))

(transpiler-pass transpiler-middleend-0 (tr)
    make-packages            #'make-packages
    expression-expand        [with-temporary (transpiler-expex-warnings? tr) nil
                               (transpiler-expression-expand tr _)]
    correct-functions        [correct-functions tr _]
    accumulate-toplevel      [accumulate-toplevel-expressions tr _]
    inject-debugging         [? (transpiler-inject-debugging? tr)
                                (inject-debugging _)
                                _]
    quote-keywords           #'transpiler-quote-keywords
    link-funinfos            #'link-funinfos
    optimize                 [? (transpiler-inject-debugging? tr)
                                _
                                (optimize _)]
    opt-tailcall             [? (transpiler-inject-debugging? tr)
                                _
                                (alet (opt-tailcall _)
                                  (? (equal ! _)
                                     !
                                     (optimize !)))]
    cps                      [? (transpiler-cps-transformation? tr)
                                (cps _)
                                _]
    opt-find-unused-places   #'opt-places-find-used
    opt-remove-unused-places #'opt-places-remove-unused
    update-funinfo           #'transpiler-update-funinfo
    print-dot                [(& *show-transpiler-progress?* (princ #\.) (force-output))
                              _])

(defun transpiler-middleend (tr x)
  (mapcan [transpiler-middleend-0 tr (list _)] x))
