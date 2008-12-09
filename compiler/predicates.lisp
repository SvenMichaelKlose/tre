;;;; TRE compiler
;;;; Copyright (c) 2006-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Miscellaneous predicates

(defun compilable? (x)
  (or (functionp x)
      (macrop x)))

(defun quote? (x)
  (and (consp x)
	   (eq 'QUOTE (car x))))

(defun backquote? (x)
  (and (consp x)
	   (eq 'BACKQUOTE (car x))))

(defun identity? (x)
  (and (consp x)
       (eq 'IDENTITY (car x))))
