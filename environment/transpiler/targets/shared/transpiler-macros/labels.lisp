(define-shared-transpiler-macro (bc c js php) labels (fdefs &body body)
  `(#'(,(@ #'first fdefs)
       ,@(@ [`(%set-local-fun ,_.  #'(,._. (block ,_. (block nil ,@.._))))] fdefs)
      ,@body)
    ,@(@ [] fdefs)))