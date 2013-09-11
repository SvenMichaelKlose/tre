;;;;; tré – Copyright (C) 2005–2006,2011,2013 Sven Michael Klose <pixel@copei.de>

(functional caar cadr cdar cddr cadar cddar caadar caddr caadr cdddr cdadar caaddr caddar cdddar cadadr cadaddr cadadar cddadar)

(early-defun caar (lst)
  (car (car lst)))

(early-defun cadr (lst)
  (car (cdr lst)))

(early-defun cdar (lst)
  (cdr (car lst)))

(early-defun cddr (lst)
  (cdr (cdr lst)))

(early-defun cadar (lst)
 (cadr (car lst)))

(early-defun cddar (lst)
 (cddr (car lst)))

(early-defun caadar (lst)
 (car (cadr (car lst))))

(early-defun caddr (lst)
 (car (cddr lst)))

(early-defun caadr (lst)
 (car (cadr lst)))

(early-defun cdddr (lst)
 (cdr (cdr (cdr lst))))

(early-defun cdadar (lst)
 (cdr (cadr (car lst))))

(early-defun caaddr (lst)
 (car (caddr lst)))

(early-defun caddar (lst)
 (caddr (car lst)))

(early-defun cdddar (lst)
 (cdddr (car lst)))

(early-defun cadadr (lst)
 (cadr (cadr lst)))

(early-defun cadaddr (lst)
 (cadr (caddr lst)))

(early-defun cadadar (lst)
 (cadr (cadr (car lst))))

(early-defun cddadar (lst)
 (cddr (cadr (car lst))))
