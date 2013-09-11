;;;; tré – Copyright (c) 2005–2006,2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro %!? (predicate &body alternatives)
  (? alternatives
     `(let ! ,predicate
        (? !
		   ,(car alternatives)
		   ,@(? (cdr alternatives)
                `((%!? ,@(cdr alternatives))))))
     predicate))

(defmacro !? (predicate &body alternatives)
  (| alternatives
     (error "!? expects at least a consequence."))
  `(%!? ,predicate ,@alternatives))

(defmacro awhen (predicate &body body)
  `(let ! ,predicate
     (when !
	   ,@body)))

(defmacro alet (obj &body body)
  `(let ! ,obj
	 ,@body))

(defmacro aprog1 (obj &body body)
  `(let ! ,obj
	 ,@body
	 !))

(defmacro adolist (params &body body)
  (let p (? (atom params)
            (list params)
            params)
    `(dolist (! ,(car p) ,(cadr p))
       ,@body)))

(defmacro adotimes (params &body body)
  (let p (? (atom params)
            (list params)
            params)
    `(dotimes (! ,(car p) ,(cadr p))
       ,@body)))
