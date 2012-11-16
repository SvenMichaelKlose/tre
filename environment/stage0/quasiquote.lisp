;;;;; tré – Copyright (c) 2008–2009,2012 Sven Michael Klose <pixel@copei.de>

(defun %quasiquote-expand (x)
  (with-cons a d x
    (?
      (atom x) x
      (atom a) (cons a (%quasiquote-expand d))
      (case a. :test #'eq
        'quote              (cons a (%quasiquote-expand d))
        'backquote          (cons a (%quasiquote-expand d))
        'quasiquote         (cons (eval .a. (%quasiquote-expand d))
        'quasiquote-splice) (+ (eval .a.) (%quasiquote-expand d))
        (cons-r %quasiquote-expand x)))))
