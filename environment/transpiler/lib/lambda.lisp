(defmacro with-lambda-call ((args vals body x) &body exec-body)
  (with-gensym (tmp fun)
    `(with (,tmp ,x
            ,fun (cadar ,tmp)
            ,args (lambda-args ,fun)
            ,vals (cdr ,tmp)
            ,body (lambda-body ,fun))
       ,@exec-body)))

(defmacro with-lambda (name args body x &body macro-body)
  (with-gensym g
    `(with (,g    ,x
            ,name (lambda-name ,g)
            ,args (lambda-args ,g)
            ,body (lambda-body ,g))
       ,@macro-body)))

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

(fn expanded-lambda-args (x)
  (argument-expand-names (lambda-name x) (lambda-args x)))
