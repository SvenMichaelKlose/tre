;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *opt-peephole?* t)

(defmacro opt-peephole-fun (fun &rest body)
  `(when x
	 (with-cons a d x
	   (?
		 (named-lambda? a)
           (cons (copy-lambda a :body (with-temporaries (*body*    (lambda-body a)
                                                         *funinfo* (get-lambda-funinfo a))
                                        (,fun *body*)))
                 (,fun d))
		 ,@body
		 (cons a (,fun d))))))

(defmacro def-opt-peephole-fun (name &rest body)
  `(defun ,name (x)
     (opt-peephole-fun ,name
       ,@body)))
