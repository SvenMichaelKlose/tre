(defvar *opt-peephole?* t)

(defmacro optimizer (fun &body body)
  `(when x
	 (with-cons a d x
	   (?
		 (named-lambda? a)
           (. (copy-lambda a :body (with-temporary *body* (lambda-body a)
                                     (with-lambda-funinfo a
                                       (,fun *body*))))
              (,fun d))
		 ,@body
		 (. a (,fun d))))))

(defmacro define-optimizer (name &body body) ; TODO: Maybe try something with METACODE-WALKER.
  `(fn ,name (x)
     (optimizer ,name
       ,@body)))
