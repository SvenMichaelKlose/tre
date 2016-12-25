(def-head-predicate %rest)
(def-head-predicate %body)
(def-head-predicate %key)
(defun %rest-or-%body? (x)    (| (%rest? x) (%body? x)))
(defun argument-synonym? (x)  (| (%rest-or-%body? x)
                                 (%key? x)))

(defun argument-rest-keyword? (x)  (in? x '&rest '&body))
(defun argument-keyword? (x)       (in? x '&rest '&body '&optional '&key))
(defun argument-name? (x)          (atom x))
(defun argument-name (x)           x)

(defun error-arguments-missing (fun args)
  (error "Arguments ~A missing for ~A." args fun))

(defun error-too-many-arguments (fun argdef args)
  (without-automatic-newline
    (error "Too many arguments ~A to ~A with argument definition ~A." args fun argdef)))

(defun error-&rest-has-value (fun)
  (error "In arguments to ~A: &REST cannot have a value." fun))

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
		     (? (eq '&key _.)
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
    (cons? vals)   vals.
    (cons? defs.)  (cadr defs.)
    defs.))

(defun argument-expand-0 (fun adef alst
                          apply-values?
                          concatenate-sublists?
                          break-on-errors?)
  (with ((a k)      (make-&key-alist adef)
	     argdefs    a
	     key-args   k
	     num        0
	     no-static  nil
	     rest-arg   nil
         err
		   #'((msg args)
                (? break-on-errors?
				   (return (error (+ "~L; In argument expansion for ~A: ~A~%"
                                     "; Argument definition: ~A~%"
                                     "; Given arguments: ~A~%")
                                  (symbol-name fun)
                                  (apply #'format nil msg args)
                                  adef
                                  alst))
                   'error))
		 exp-static
		   #'((def vals)
			    (& no-static
				   (return (err "Static argument definition after ~A."
                                (list no-static))))
			    (& apply-values? (not vals)
				   (return (err "Argument ~A missing." (list num))))
				(. (. (argdef-get-name def.) vals.)
                   (exp-main .def .vals)))

		 exp-optional
		   #'((def vals)
				(& (argument-keyword? def.)
				   (return (err "Keyword ~A after &OPTIONAL." (list def.))))
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
                       (| .! (return (err "Value of argument ~A missing." (list !.))))
					   (rplacd k .!.)
					   (exp-main def ..!))
					 (exp-main-non-key def vals))))

		 exp-rest
		   #'((synonym def vals)
				(= no-static '&rest)
  			    (= rest-arg (list (. (argdef-get-name .def.)
                                     (. synonym vals))))
			    nil)

         exp-optional-rest
		   #'((def vals)
		        (case def. :test #'eq
				  '&rest     (exp-rest '%rest def vals)
				  '&body     (exp-rest '%body def vals)
				  '&optional (exp-optional .def vals)))

		 exp-sub
		   #'((def vals)
			    (& no-static
				   (return (err "Static sublevel argument definition after ~A." (list no-static))))
				(& apply-values? (atom vals.)
				   (return (err "Sublist expected for argument ~A." (list num))))
                (? concatenate-sublists?
				   (nconc (argument-expand-0 fun def. vals.
                                             apply-values?
                                             concatenate-sublists?
                                             break-on-errors?)
					       (exp-main .def .vals))
				   (. (. nil (argument-expand-0 fun def. vals.
                                                apply-values?
                                                concatenate-sublists?
                                                break-on-errors?))
					  (exp-main .def .vals))))

		 exp-check-too-many
           #'((def vals)
			    (& (not def) vals
				   (return (err "Too many arguments. Maximum is ~A, but ~A more given."
                                (list (length argdefs) (length vals))))))

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

	 (alet (exp-main argdefs alst)
       (? (eq ! 'error)
          !
	      (nconc ! (nconc (@ [. _. (. '%key ._)] key-args)
                          rest-arg))))))

(defun argument-expand (fun def vals &key (apply-values? t)
                                          (concatenate-sublists? t)
                                          (break-on-errors? t))
  (alet (argument-expand-0 fun def vals apply-values? concatenate-sublists? break-on-errors?)
    (? (| apply-values?
          (eq ! 'error))
       !
       (carlist !))))

(defun argument-expand-names (fun def)
  (argument-expand fun def nil :apply-values? nil))

(defun argument-expand-values (fun def vals &key (break-on-errors? t))
  (@ [? (argument-synonym? _)
        ._
        _]
     (cdrlist (argument-expand fun def vals :break-on-errors? break-on-errors?))))
