(fn make-lambda (&key (name nil) args body)
  `(function
     ,@(!? name
           (list !))
     (,args
      ,@body)))

(fn copy-lambda (x &key (name nil) (args 'no-args) (body 'no-body))
  `(function
     ,@(!? (| name (lambda-name x))
           (list !))
     (,(? (eq 'no-args args)
          (lambda-args x)
          args)
      ,@(? (eq 'no-body body)
           (lambda-body x)
           body))))

(defmacro with-lambda (name args body x &body macro-body)
  (with-gensym g
    `(with (,g     ,x
            ,name  (lambda-name ,g)
            ,args  (lambda-args ,g)
            ,body  (lambda-body ,g))
       ,@macro-body)))

(defmacro with-binding-lambda ((args vals body x) &body exec-body)
  (with-gensym (tmp fun)
    `(with (,tmp   ,x
            ,fun   (cadar ,tmp)
            ,vals  (cdr ,tmp)
            ,args  (lambda-args ,fun)
            ,body  (lambda-body ,fun))
       ,@exec-body)))
