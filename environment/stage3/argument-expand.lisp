;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun argument-rest-keyword? (x)     (in? x (make-symbol "&REST" "TRE") (make-symbol "&BODY" "TRE")))
(defun argument-keyword? (x)          (in? x (make-symbol "&REST" "TRE") (make-symbol "&BODY" "TRE") (make-symbol "&OPTIONAL" "TRE") (make-symbol "&KEY" "TRE")))
(defun argument-name? (x)             (atom x))
(defun argument-name (x)              x)

(defun error-arguments-missing (fun args)
  (error "Arguments ~A missing for function ~A." fun args))

(defun error-too-many-arguments (fun args)
  (error "Too many arguments ~A for function ~A." args fun))

(defun error-&rest-has-value (fun)
  (error "In function ~A: &REST cannot have a value." fun))

(defun make-&key-alist (def)
  (with (keys nil
		 make-&key-descr
		   [when _
			 (? (argument-keyword? _.)
				(copy-def-until-&key _)
				(alet _.
                  (push (? (cons? !)
                           (. !. .!.) ; with default value
                           (. ! !))   ; with itself
                        keys)
                  (make-&key-descr ._)))]

		 copy-def-until-&key
		   [when _
		     (? (eq (make-symbol "&KEY" "TRE") _.)
				(make-&key-descr ._)
				(. _. (copy-def-until-&key ._)))])

	(values (copy-def-until-&key def)
            (reverse keys))))

(defun argdef-get-name (x)
  (? (cons? x)
     x.
     x))

(defun argdef-get-default (x)
  (? (cons? x)
     .x.
     x))

(defun argdef-get-value (defs vals)
  (?
    (cons? vals)  vals.
    (cons? defs.) (cadr defs.)
    defs.))

(defun argument-expand-0 (fun adef alst apply-values? concatenate-sublists?)
  (with ((a k)      (make-&key-alist adef)
	     argdefs    a
	     key-args   k
	     num        0
	     no-static  nil
	     rest-arg   nil
         err
		   #'((msg args)
				(error "; Call of function ~A: ~A~%; Argument definition: ~A~%; Given arguments: ~A~%"
                       (symbol-name fun)
                       (apply #'format nil msg args)
                       adef
                       alst))
		 exp-static
		   #'((def vals)
			    (& no-static
				   (err "static argument definition after ~A" (list no-static)))
			    (& apply-values? (not vals)
				   (err "argument ~A missing" (list num)))
				(. (. (argdef-get-name def.) vals.)
                   (exp-main .def .vals)))

		 exp-optional
		   #'((def vals)
				(& (argument-keyword? def.)
				   (err "Keyword ~A after &OPTIONAL" (list def.)))
				(= no-static '&optional)
				(. (. (argdef-get-name def.)
				      (argdef-get-value def vals))
				   (?
					 (argument-keyword? .def.)  (exp-main .def .vals)
					 .def                       (exp-optional .def .vals)
					 (exp-main .def .vals))))

		 exp-key
		   #'((def vals)
			    (let k (assoc ($ vals.) key-args :test #'eq)
				  (? k
			         (alet vals
					   (rplacd k .!.) ; check if key-value exists.
					   (exp-main def ..!))
					 (exp-main-non-key def vals))))

		 exp-rest
		   #'((def vals)
				(= no-static '&rest)
  			    (= rest-arg (list (. (argdef-get-name .def.)
                                     (. def. vals))))
			    nil)

         exp-optional-rest
		   #'((def vals)
		        (case def. :test #'eq
				  (make-symbol "&REST" "TRE")     (exp-rest def vals)
				  (make-symbol "&BODY" "TRE")     (exp-rest def vals)
				  (make-symbol "&OPTIONAL" "TRE") (exp-optional .def vals)))

		 exp-sub
		   #'((def vals)
			    (& no-static
				   (err "static sublevel argument definition after ~A" (list no-static)))
				(& apply-values? (atom vals.)
				   (err "sublist expected for argument ~A" (list num)))
                (? concatenate-sublists?
				   (%nconc (argument-expand-0 fun def. vals. apply-values? concatenate-sublists?)
					       (exp-main .def .vals))
				   (. (. nil (argument-expand-0 fun def. vals. apply-values? concatenate-sublists?))
					  (exp-main .def .vals))))

		 exp-check-too-many
           #'((def vals)
			    (& (not def) vals
				   (err "too many arguments. ~A max, but ~A more given" (list (length argdefs) (length vals)))))

		 exp-main-non-key
		   #'((def vals)
				(exp-check-too-many def vals)
				(?
				  (argument-keyword? def.)     (exp-optional-rest def vals)
				  (not (argument-name? def.))  (exp-sub def vals)
				  (exp-static def vals)))

         exp-main
		   #'((def vals)
			    (++! num)
			    (? (keyword? vals.)
				   (exp-key def vals)
				   (| (exp-check-too-many def vals)
			          (& def
                         (exp-main-non-key def vals))))))

	 (%nconc (exp-main argdefs alst)
			 (%nconc key-args rest-arg))))

(defun argument-expand (fun def vals &key (apply-values? t) (concatenate-sublists? t))
  (? apply-values?
	 (argument-expand-0 fun def vals apply-values? concatenate-sublists?)
	 (carlist (argument-expand-0 fun def vals apply-values? concatenate-sublists?))))

(defun argument-expand-names (fun def)
  (argument-expand fun def nil :apply-values? nil))

(defun argument-expand-values (fun def vals)
  (filter [? (& (cons? _)
                (argument-rest-keyword? _.))
             ._
             _]
          (cdrlist (argument-expand fun def vals))))
