; Translate
;   (%= X (FUNCTION NAME ARGS+BODY))
; to
;   (FUNCTION NAME ARGS+BODY)
;   (%= X NAME)

(fn unassign-named-functions (x)
  (& x
     (!= x.
       (?
         (named-lambda? !)
           (. (copy-lambda ! :body (unassign-named-functions (lambda-body !)))
              (unassign-named-functions .x))
         (& (%=? !)
            (named-lambda? ..!.))
           (!= ..!.
             `(,(copy-lambda ! :body (unassign-named-functions (lambda-body !)))
               ,@(unless (lambda-export?)
                   `((%= ,(cadr x.) ,(lambda-name !))))
               ,@(unassign-named-functions .x)))
         (. ! (unassign-named-functions .x))))))
