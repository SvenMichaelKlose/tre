; tré – Copyright (c) 2009,2012,2015–2016 Sven Michael Klose <pixel@copei.de>

(defmacro mapcar-macro (arg param &body body)
  `{,@(@ [eval (macroexpand `(#'((,arg) ,@body) ',_))]
         (eval param))})

(defmacro mapcan-macro (arg param &body body)
  `{,@(mapcan [eval (macroexpand `(#'((,arg) ,@body) ',_))]
              (eval param))})
