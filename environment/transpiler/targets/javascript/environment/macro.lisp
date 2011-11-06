;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

,(? *have-compiler*
    '(defun macrop (name)
	   (expander-has-macro? 'standard-macros name))
    '(defun macrop (x)))

,(when *have-compiler?*
   '(defmacro define-std-macro (name &rest args-and-body)
      (let quoted-name (list 'quote name)
        `(progn
           (when (expander-has-macro? 'standard-macros ,quoted-name)
	         (warn "Macro ~A is already defined." ,quoted-name))
           (define-expander-macro standard-macros ,name ,@args-and-body)))))

,(when *have-compiler?*
  '(defun macroexpand (x)
     (expander-expand 'standard-macros x)))
