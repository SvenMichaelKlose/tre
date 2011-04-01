;;;;; TRE transpiler environment
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun maparray (fun hash)
  (dotimes (i (length hash))
    (funcall fun (aref hash i))))

(defun maphash (fun hash)
  (dolist (i (%property-list hash))
    (funcall fun i. .i)))

(defun elt (seq idx)
  (?
    (string? seq) (%elt-string seq idx)
    (cons? seq) (nth idx seq)
  	(aref seq idx)))

(defun (setf elt) (val seq idx)
  (?
	,@(when *transpiler-assert*
        '((string? seq) (error "strings cannot be modified")))
	(arrayp seq) (setf (aref seq idx) val)
	(cons? seq) (rplaca (nthcdr idx seq) val)))
