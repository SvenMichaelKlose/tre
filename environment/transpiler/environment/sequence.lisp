;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun maparray (fun hash)
  (with-queue q
    (dotimes (i (length hash) (queue-list q))
      (enqueue q (funcall fun (aref hash i))))))

(defun maphash (fun hash)
  (dolist (i (%property-list hash))
    (funcall fun i. .i)))

(defun elt (seq idx)
  (?
    (string? seq) (%elt-string seq idx)
    (cons? seq)   (nth idx seq)
  	(aref seq idx)))

(defun (= elt) (val seq idx)
  (?
	,@(when (transpiler-assert? *current-transpiler*)
        '((string? seq) (error "strings cannot be modified")))
	(array? seq) (= (aref seq idx) val)
	(cons? seq)  (rplaca (nthcdr idx seq) val)))
