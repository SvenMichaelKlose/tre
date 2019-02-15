(fn maparray (fun hash)
  (with-queue q
    (dotimes (i (length hash) (queue-list q))
      (enqueue q (funcall fun (aref hash i))))))

(fn maphash (fun hash)
  (@ (i (%properties-list hash))
    (funcall fun i. .i)))

(fn elt (seq idx)
  (?
    (string? seq) (%elt-string seq idx)
    (cons? seq)   (nth idx seq)
    (aref seq idx)))

(fn (= elt) (val seq idx)
  (?
    ,@(& (assert?)
         '((string? seq) (error "Strings cannot be modified.")))
    (array? seq) (= (aref seq idx) val)
    (cons? seq)  (rplaca (nthcdr idx seq) val)))
