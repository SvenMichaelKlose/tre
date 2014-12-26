; tré – Copyright (c) 2008,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun correct-functions (x)
  (alet x.
    (?
      (not x) x
      (named-lambda? !)
            (. (copy-lambda ! :body (correct-functions (lambda-body !)))
               (correct-functions .x))
      (& (%=? !)
         (named-lambda? (%=-value !)))
          (alet (%=-value !)
            `(,(copy-lambda ! :body (correct-functions (lambda-body !)))
              ,@(& (not (lambda-export?))
                   `((%= ,(%=-place x.) ,(lambda-name !))))
              ,@(correct-functions .x)))
      (%%block? !)
        (cons-r correct-functions x)
      (. ! (correct-functions .x)))))
