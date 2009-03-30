;;;; TRE compiler
;;;; Copyright (c) 2006-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; Miscellaneous predicates

(defun compilable? (x)
  (or (functionp x)
      (macrop x)))

(defun quote? (x)
  (and (consp x)
	   (eq 'QUOTE x.)))

(defun %quote? (x)
  (and (consp x)
	   (eq '%QUOTE x.)))

(defun backquote? (x)
  (and (consp x)
	   (eq 'BACKQUOTE x.)))

(defun identity? (x)
  (and (consp x)
       (eq 'IDENTITY x.)))

(defun function-ref-expr? (x)
  (and (consp x)
       (eq 'FUNCTION x.)
	   (atom (second x))))

(defun %new? (x)
  (and (consp x)
	   (eq '%NEW x.)))
