(var *tag-counter* 1)

(fn make-compiler-tag ()
  (++! *tag-counter*))

(defmacro with-compiler-tag (tags &body body)
  `(with ,(mapcan [`(,_ (make-compiler-tag))]
                  (ensure-list tags))
     ,@body))
