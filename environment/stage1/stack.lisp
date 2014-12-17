;;;;; tré – Copyright (c) 2005–2008,2011–2012 Sven Michael Klose <pixel@copei.de>

(defmacro push (elm expr)
;  (& (cons? elm)
;     (eq 'cons (car elm))
;     (princ "; HINT: Macro PUSH: CONSed element: you may want to consider using ACONS! instead")
;     (terpri))
  `(= ,expr (cons ,elm ,expr)))

(defmacro pop (expr)
  `(let ret (car ,expr)
     (= ,expr (cdr ,expr))
     ret))

(defun pop! (args)
  (let ret (car args)
    (= (car args) (cadr args)
       (cdr args) (cddr args))
    ret))
