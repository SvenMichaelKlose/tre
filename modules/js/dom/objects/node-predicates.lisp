(defmacro define-dom-node-predicate (which type)
  `(fn ,($ which '?) (x)
     (& (object? x)
        (string== ,(string type) x.node-type))))

(progn
  ,@(@ [`(define-dom-node-predicate ,_. ,._.)]
       '((element 1)
         (text 3)
         (comment 8)
         (document 9))))
