;;;; tré – Copyright (c) 2005–2008,2011–2012,2014 Sven Michael Klose <pixel@copei.de>

(defmacro push (elm expr)
;  (& (cons? elm)
;     (eq 'cons elm.)
;     (princ "; HINT: Macro PUSH: CONSed element: you may want to consider using ACONS! instead")
;     (terpri))
  `(= ,expr (. ,elm ,expr)))

(defmacro pop (expr)
  `(let ret (car ,expr)
     (= ,expr (cdr ,expr))
     ret))

(defun pop! (args)
  (let ret args.
    (= args. .args.
       .args ..args)
    ret))
