;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defvar *opt-peephole?* t)

(defmacro optimizer (fun &body body)
  `(when x
	 (with-cons a d x
	   (?
		 (named-lambda? a)
           (. (copy-lambda a :body (with-temporaries (*body*    (lambda-body a)
                                                      *funinfo* (get-lambda-funinfo a))
                                      (,fun *body*)))
                 (,fun d))
		 ,@body
		 (. a (,fun d))))))

(defmacro define-optimizer (name &body body)
  `(defun ,name (x)
     (optimizer ,name
       ,@body)))
