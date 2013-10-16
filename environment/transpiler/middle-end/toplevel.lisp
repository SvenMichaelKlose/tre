;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(transpiler-pass transpiler-middleend-0 (tr)
    make-packages            #'make-packages
    fake-place-expand        #'fake-place-expand
    expression-expand        #'expression-expand
    correct-functions        #'correct-functions
    accumulate-toplevel      [? (transpiler-accumulate-toplevel-expressions? tr)
                                (accumulate-toplevel-expressions _)
                                _]
    inject-debugging         [? (transpiler-inject-debugging? tr)
                                (inject-debugging _)
                                _]
    quote-keywords           #'transpiler-quote-keywords
    optimize                 [? (transpiler-inject-debugging? tr)
                                _
                                (optimize _)]
    opt-tailcall             [? (transpiler-inject-debugging? tr)
                                _
                                (alet (opt-tailcall _)
                                  (? (equal ! _)
                                     !
                                     (optimize !)))]
    cps                      [funcall #'cps _])

(defun transpiler-middleend (tr x)
  (mapcan [transpiler-middleend-0 tr (list _)] x))
