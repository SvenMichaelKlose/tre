(var *tag-counter* 1)

(fn make-compiler-tag ()
  (++! *tag-counter*))

(defmacro with-metacode-tag (tags &body body)
  `(with ,(+@ [`(,_ (make-compiler-tag))]
              (ensure-list tags))
     ,@body))
