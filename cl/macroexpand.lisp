;;;;; tré – Copyright (c) 2006–2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defun %macroexpand-backquote (x)
  (?
    (atom x) x
    (atom (car x))
        (cons (car x)
              (%macroexpand-backquote (cdr x)))

    (eq (car (car x)) 'QUASIQUOTE)
        (cons (cons 'QUASIQUOTE
                    (%macroexpand (cdr (car x))))
              (%macroexpand-backquote (cdr x)))

    (eq (car (car x)) 'QUASIQUOTE-SPLICE)
        (cons (cons 'QUASIQUOTE-SPLICE
                    (%macroexpand (cdr (car x))))
              (%macroexpand-backquote (cdr x)))

    (cons (%macroexpand-backquote (car x))
          (%macroexpand-backquote (cdr x)))))

(defun %macroexpand-rest (x)
  (? (atom x)
     x
     (cons (early-macroexpand-1 (car x))
           (%macroexpand-rest (cdr x)))))

(defun %macroexpand-call (x)
  (? (and (symbol? (car x))
          (%%%macro? (car x)))
     (%%macrocall x)
     x))

(defun early-macroexpand-1 (x)
  (?
    (atom x) x
    (eq (car x) 'QUOTE)             x
    (eq (car x) 'BACKQUOTE)         (cons 'BACKQUOTE (%macroexpand-backquote (cdr x)))
    (eq (car x) 'QUASIQUOTE)        (cons 'QUASIQUOTE (early-macroexpand-1 (cdr x)))
    (eq (car x) 'QUASIQUOTE-SPLICE) (cons 'QUASIQUOTE-SPLICE (early-macroexpand-1 (cdr x)))
    (%macroexpand-call (%macroexpand-rest x))))

(defun early-macroexpand-0 (old x)
  (? (equal x old)
     old
     (early-macroexpand x)))

(defun early-macroexpand (x)
  (early-macroexpand-0 x (early-macroexpand-1 x)))
