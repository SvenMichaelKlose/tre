;;;;; tré – Copyright (c) 2008,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun correct-functions (x)
  (?
    (not x) x
    (named-lambda? x.)
        (alet x.
          (. (copy-lambda ! :body (correct-functions (lambda-body !)))
             (correct-functions .x)))
    (& (%=? x.)
       (named-lambda? (%=-value x.)))
        (alet (%=-value x.)
          `(,(copy-lambda ! :body (correct-functions (lambda-body !)))
            ,@(& (not (transpiler-lambda-export? *transpiler*))
                 `((%= ,(%=-place x.) ,(lambda-name !))))
            ,@(correct-functions .x)))
    (%%block? x.)
      (cons-r correct-functions x)
    (. x. (correct-functions .x))))
