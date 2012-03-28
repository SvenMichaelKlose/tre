;;;;; tré - Copyright (c) 2005-2008,2011-2012 Sven Michael Klose <pixel@copei.de>

(defmacro push (elm expr)
  (? (and (cons? elm)
          (eq 'cons (car elm)))
     (progn
       (princ "; HINT: Macro PUSH: CONSed element: you may want to consider using ACONS! instead")
       (terpri)))
  `(setf ,expr (cons ,elm ,expr)))

(defmacro pop (expr)
  `(let ret (car ,expr)
     (setf ,expr (cdr ,expr))
     ret))

(defun pop! (args)
  (let ret (car args)
    (setf (car args) (cadr args)
          (cdr args) (cddr args))
    ret))
