;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>

(%defun caar (lst)
  (car (car lst)))

(%defun cadr (lst)
  (car (cdr lst)))

(%defun cdar (lst)
  (cdr (car lst)))

(%defun cddr (lst)
  (cdr (cdr lst)))

(%defun cadar (lst)
 (car (cdr (car lst))))

(%defun cddar (lst)
 (cdr (cdr (car lst))))

(%defun caadar (lst)
 (car (car (cdr (car lst)))))

(%defun caddr (lst)
 (car (cdr (cdr lst))))

(%defun caadr (lst)
 (car (car (cdr lst))))

(%defun cdddr (lst)
 (cdr (cdr (cdr lst))))

(%defun cdadar (lst)
 (cdr (car (cdr (car lst)))))

(%defun caaddr (lst)
 (car (car (cdr (cdr lst)))))

(%defun caddar (lst)
 (car (cdr (cdr (car lst)))))

(%defun cadadar (lst)
 (car (cdr (car (cdr (car lst))))))

(%defun cddadar (lst)
 (cdr (cdr (car (cdr (car lst))))))
