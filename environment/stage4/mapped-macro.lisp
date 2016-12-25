(defmacro mapcar-macro (arg param &body body)
  `{,@(@ [eval (macroexpand `(#'((,arg) ,@body) ',_))]
         (eval param))})

(defmacro mapcan-macro (arg param &body body)
  `{,@(mapcan [eval (macroexpand `(#'((,arg) ,@body) ',_))]
              (eval param))})
