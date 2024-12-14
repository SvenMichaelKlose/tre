(defmacro do (vars (test &rest result) &body body)
  (let tag (gensym)
    `(block nil
       (let* ,(mapcar [`(,_. ,._.)] vars)
         (tagbody
           ,tag
           (? ,test
              (return (progn ,@result)))
           ,@body
           ,@(mapcan [& .._.  `((setq ,_. ,.._.))] vars)
           (go ,tag))))))

(defmacro while (test result &body body)
  `(do ()
       ((not ,test) ,result)
     ,@body))
