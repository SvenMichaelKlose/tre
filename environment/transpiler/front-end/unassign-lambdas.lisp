; tré – Copyright (c) 2008,2012–2014 Sven Michael Klose <pixel@copei.de>

; Translate
;   (%= X (FUNCTION NAME ARGS+BODY))
; to
;   (FUNCTION NAME ARGS+BODY)
;   (%= X NAME)

(defun unassign-lambdas (x)
  (alet x.
    (?
      (not x) x
      (named-lambda? !)
            (. (copy-lambda ! :body (unassign-lambdas (lambda-body !)))
               (unassign-lambdas .x))
      (& (%=? !)
         (named-lambda? (%=-value !)))
          (alet (%=-value !)
            `(,(copy-lambda ! :body (unassign-lambdas (lambda-body !)))
              ,@(unless (lambda-export?)
                  `((%= ,(%=-place x.) ,(lambda-name !))))
              ,@(unassign-lambdas .x)))
      (%%block? !)
        (cons-r unassign-lambdas x)
      (. ! (unassign-lambdas .x)))))
