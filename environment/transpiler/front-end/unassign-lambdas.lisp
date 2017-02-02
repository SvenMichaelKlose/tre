; Translate
;   (%= X (FUNCTION NAME ARGS+BODY))
; to
;   (FUNCTION NAME ARGS+BODY)
;   (%= X NAME)

(fn unassign-lambdas (x)
  (alet x.
    (& x
       (?
         (named-lambda? !)
           (. (copy-lambda ! :body (unassign-lambdas (lambda-body !)))
              (unassign-lambdas .x))
         (& (%=? !)
            (named-lambda? ..!.))
           (alet ..!.
             `(,(copy-lambda ! :body (unassign-lambdas (lambda-body !)))
               ,@(unless (lambda-export?)
                   `((%= ,(cadr x.) ,(lambda-name !))))
               ,@(unassign-lambdas .x)))
         (%%block? !)
           (cons-r unassign-lambdas x)
         (. ! (unassign-lambdas .x))))))
