(defmacro %!? (predicate &body alternatives)
  (? alternatives
     `(let ! ,predicate
        (? !
		   ,alternatives.
		   ,@(? .alternatives
                `((%!? ,@.alternatives)))))
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
  (warn "Macro ADOLIST is deprecated. Consider it gone soon.")
  (let p (? (atom params)
            (list params)
            params)
    `(dolist (! ,p. ,.p.)
       ,@body)))

(defmacro adotimes (params &body body)
  (let p (? (atom params)
            (list params)
            params)
    `(dotimes (! ,p. ,.p.)
       ,@body)))
