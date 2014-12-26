; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(transpiler-pass middleend-0 ()
    print-dot                [(& *development?*
                                 (format t ".~F"))
                              _]
    make-packages            #'make-packages
    expression-expand        #'expression-expand
    correct-functions        #'correct-functions
    accumulate-toplevel      [? (accumulate-toplevel-expressions?)
                                (accumulate-toplevel-expressions _)
                                _]
    inject-debugging         [? (inject-debugging?)
                                (inject-debugging _)
                                _]
    quote-keywords           #'quote-keywords
    optimize                 [? (inject-debugging?)
                                _
                                (optimize _)]
    opt-tailcall             [? (inject-debugging?)
                                _
                                (alet (opt-tailcall _)
                                  (? (equal ! _)
                                     !
                                     (optimize !)))]
    cps                      [? (cps-transformation?)
                                (funcall #'cps _)
                                _])

(defun middleend (x)
  (mapcan [middleend-0 (list _)] x))
