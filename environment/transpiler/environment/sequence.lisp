(defun maparray (fun hash)
  (with-queue q
    (dotimes (i (length hash) (queue-list q))
      (enqueue q (funcall fun (aref hash i))))))

(defun maphash (fun hash)
  (@ (i (%property-list hash))
    (funcall fun i. .i)))

(defun elt (seq idx)
  (?
    (string? seq) (%elt-string seq idx)
    (cons? seq)   (nth idx seq)
  	(aref seq idx)))

(defun (= elt) (val seq idx)
  (?
	,@(& (assert?)
         '((string? seq) (error "Strings cannot be modified.")))
	(array? seq) (= (aref seq idx) val)
	(cons? seq)  (rplaca (nthcdr idx seq) val)))
