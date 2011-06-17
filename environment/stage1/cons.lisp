;;;; TRE environment
;;;; Copyright (C) 2005-2006,2011 Sven Klose <pixel@copei.de>

(%defun caar (lst)
  (car (car lst)))

(%defun cadr (lst)
  (car (cdr lst)))

(%defun cdar (lst)
  (cdr (car lst)))

(%defun cddr (lst)
  (cdr (cdr lst)))

(%defun cadar (lst)
 (cadr (car lst)))

(%defun cddar (lst)
 (cddr (car lst)))

(%defun caadar (lst)
 (car (cadr (car lst))))

(%defun caddr (lst)
 (car (cddr lst)))

(%defun caadr (lst)
 (car (cadr lst)))

(%defun cdddr (lst)
 (cdr (cdr (cdr lst))))

(%defun cdadar (lst)
 (cdr (cadr (car lst))))

(%defun caaddr (lst)
 (car (caddr lst)))

(%defun caddar (lst)
 (caddr (car lst)))

(%defun cdddar (lst)
 (cdddr (car lst)))

(%defun cadadr (lst)
 (cadr (cadr lst)))

(%defun cadaddr (lst)
 (cadr (caddr lst)))

(%defun cadadar (lst)
 (cadr (cadr (car lst))))

(%defun cddadar (lst)
 (cddr (cadr (car lst))))
