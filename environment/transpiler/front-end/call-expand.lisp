(fn compile-list (x)
  (? (cons? x)
     `(. ,x. ,(compile-list .x))
     x))

(fn compile-expanded-argument (x)
  (?
    (%rest-or-%body? x) (compile-list .x)
    (%key? x)           .x
    x))

(fn compile-expanded-arguments (fun def vals)
  (call-expand (@ #'compile-expanded-argument
                  (cdrlist (argument-expand fun def vals)))))

(fn call-expand-argdef (fun)
  ; TODO: The variable containing the function gets assigned to another one…
  ;(| (!? (funinfo-get-local-function-args *funinfo* fun)
         ;(print !)) ; …so this doesn't happen.
  (transpiler-function-arguments *transpiler* fun))

(fn call-expand-call (x)
  (when (atom x)
    (return x))
  (with (new? (%new? x)
         fun  (? new? .x. x.)
         args (? new? ..x .x))
    `(,@(& new? '(%new))
      ,fun
      ,@(? (defined-function fun)
           (compile-expanded-arguments fun (call-expand-argdef fun) args)
           args))))

(fn call-expand-expr (x)
  (pcase x
    atom x
    %=?
      `(%= ,.x. ,(call-expand-expr ..x.))
    conditional-%go?
      `(,x. ,.x. ,(call-expand-expr ..x.))
    %var?   ; Move to var collecting pass.
      (progn
        (funinfo-add-var *funinfo* .x.)
        nil)
    named-lambda?
      (do-lambda x :body (call-expand (lambda-body x)))
    %block?
      `(%block
         ,@(call-expand .x))
    unexpex-able?
      x
    %collection?
      `(%collection ,.x.
         ,@(@ [. '%inhibit-macro-expansion
                 (. ._.
                    (? .._
                       (cdr (call-expand .._))))]
              ..x))
    (call-expand-call x)))

(define-filter call-expand #'call-expand-expr)
