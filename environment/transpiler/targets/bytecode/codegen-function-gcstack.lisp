;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun bc-codegen-function-prologue-for-local-variables (fi)
  `((%%%num-vars ,(length (funinfo-env fi)))
    ,@(codegen-copy-arguments-to-locals fi)))

(define-bc-macro %function-epilogue (fi-sym))
(define-bc-macro %function-return (fi-sym))
