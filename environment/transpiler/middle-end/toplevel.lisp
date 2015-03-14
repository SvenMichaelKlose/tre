; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@hugbox.org>

(def-pass-fun pass-accumulate-toplevel-expression x
  (? (accumulate-toplevel-expressions?)
     (accumulate-toplevel-expressions x)
     x))

(def-pass-fun pass-inject-debugging x
  (? (inject-debugging?)
     (inject-debugging x)
     x))

(def-pass-fun pass-optimize x
  (? (inject-debugging?)
     x
     (optimize x)))

(def-pass-fun pass-opt-tailcall x
  (? (inject-debugging?)
     x
     (alet (opt-tailcall x)
       (? (equal ! x)
          !
          (optimize !)))))

(def-pass-fun pass-cps x
  (? (cps-transformation?)
     (funcall #'cps x)
     x))
 
(transpiler-pass middleend-0
    print-dot                [(& *development?*
                                 (format t ".~F"))
                              _]
    make-packages            #'make-packages
    expression-expand        #'expression-expand
    correct-functions        #'correct-functions
    accumulate-toplevel      #'pass-accumulate-toplevel-expressions
    inject-debugging         #'pass-inject-debugging
    quote-keywords           #'quote-keywords
    optimize                 #'pass-optimize
    opt-tailcall             #'pass-opt-tailcall
    cps                      #'pass-cps)

(defun middleend (x)
  (? (frontend-only?)
     x
     (mapcan [middleend-0 (list _)] x)))
