(fn make-lambda (&key (name nil) args body)
  `(function ,@(ensure-list name)
     (,args
      ,@body)))

(fn copy-lambda (x &key (name nil) (args 'no-args) (body 'no-body))
  `(function
     ,@(ensure-list (| name (lambda-name x)))
     (,(? (eq 'no-args args)
          (lambda-args x)
          args)
      ,@(? (eq 'no-body body)
           (lambda-body x)
           body))))

(defmacro with-lambda (name args body x &body macro-body)
  (with-gensym g
    `(with (,g    ,x
            ,name (lambda-name ,g)
            ,args (lambda-args ,g)
            ,body (lambda-body ,g))
       ,@macro-body)))

(fn lambda-funinfo (x)
  (get-funinfo (lambda-name x)))

(defmacro with-lambda-funinfo (x &body body)
  `(with-temporary *funinfo* (lambda-funinfo ,x)
     (with-temporary *body* (lambda-body ,x)
       ,@body)))

(defmacro do-lambda (x &key (name nil) (args 'no-args) (body 'no-body))
  (with-gensym g
    `(with (,g ,x)
       (with-lambda-funinfo ,g
         (copy-lambda ,g :name ,name :args ,args :body ,body)))))

(defmacro with-binding-lambda ((args vals body x) &body exec-body)
  (with-gensym (tmp fun)
    `(with (,tmp  ,x
            ,fun  (cadar ,tmp)
            ,vals (cdr ,tmp)
            ,args (lambda-args ,fun)
            ,body (lambda-body ,fun))
       ,@exec-body)))
