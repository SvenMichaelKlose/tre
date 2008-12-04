;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005,2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Basic conditional operators

(defmacro if (predicate consequent &optional (alternative nil))
  `(cond
     (,predicate ,consequent)
     (t ,alternative)))

(%defun compiler-and (x)
  (cond
    ((cdr x)
      `(cond
        (,(car x) ,(compiler-and (cdr x)))))
    (t       (car x))))

(defmacro and (&rest x)
  (compiler-and x))

(%defun compiler-or (x)
  (cond
    ((cdr x)
      (let g (gensym)
        `(let ,g ,(car x)
          (cond
            ((not ,g) ,(compiler-or (cdr x)))
            (t ,g)))))
    (t (car x))))

(defmacro or (&rest exprs)
  (compiler-or exprs))
