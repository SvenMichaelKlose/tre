;;;;; TRE compiler
;;;;; Copyright (c) 2005-2009,2011 Sven Klose <pixel@copei.de>

(defmacro with-lambda-call ((args vals body call) &rest exec-body)
  (with-gensym (tmp fun)
    `(with (,tmp ,call
            ,fun (cadar ,tmp)
            ,args (lambda-args ,fun)
            ,vals (lambda-call-vals ,tmp)
            ,body (lambda-body ,fun))
       ,@exec-body)))
