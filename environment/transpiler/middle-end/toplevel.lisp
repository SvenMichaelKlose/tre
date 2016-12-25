; tré – Copyright (c) 2008–2016 Sven Michael Klose <pixel@hugbox.org>

(defun pass-optimize (x)
  (? (enabled-pass? :inject-debugging)
     x
     (optimize x)))

(defun pass-opt-tailcall (x)
  (? (enabled-pass? :inject-debugging)
     x
     (alet (opt-tailcall x)
       (? (equal ! x)
          !
          (optimize !)))))

(define-transpiler-end :middleend
    middleend-input          #'identity
    expression-expand        #'expression-expand
    unassign-lambdas         #'unassign-lambdas
    accumulate-toplevel      #'accumulate-toplevel-expressions
    inject-debugging         #'inject-debugging
    quote-keywords           #'quote-keywords
    optimize                 #'pass-optimize
    opt-tailcall             #'pass-opt-tailcall)
