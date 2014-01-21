;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(transpiler-pass middleend-0 ()
    make-packages            #'make-packages
    expression-expand        #'expression-expand
    correct-functions        #'correct-functions
    accumulate-toplevel      [? (transpiler-accumulate-toplevel-expressions? *transpiler*)
                                (accumulate-toplevel-expressions _)
                                _]
    inject-debugging         [? (transpiler-inject-debugging? *transpiler*)
                                (inject-debugging _)
                                _]
    quote-keywords           #'transpiler-quote-keywords
    optimize                 [? (transpiler-inject-debugging? *transpiler*)
                                _
                                (optimize _)]
    opt-tailcall             [? (transpiler-inject-debugging? *transpiler*)
                                _
                                (alet (opt-tailcall _)
                                  (? (equal ! _)
                                     !
                                     (optimize !)))]
    cps                      [? (transpiler-cps-transformation? *transpiler*)
                                (funcall #'cps _)
                                _])

(defun middleend (x)
  (mapcan [middleend-0 (list _)] x))
