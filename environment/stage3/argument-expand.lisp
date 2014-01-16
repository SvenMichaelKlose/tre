;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun argument-rest-keyword? (x) (in? x '&rest '&body))
(defun argument-keyword? (x)      (in? x '&rest '&body '&optional '&key))
(defun argument-name? (x)         (atom x))
(defun argument-name (x)          x)

(defun argument-def-without-type (x)
  x)

(defun error-arguments-missing (fun args)
  (throw "Arguments ~A missing for function ~A." fun args))

(defun error-too-many-arguments (fun args)
  (throw "Too many arguments ~A for function ~A." args fun))

(defun error-&rest-has-value (fun)
  (throw "In function ~A: &REST cannot have a value." fun))

(defun make-&key-alist (def)
  (with (&keys nil
		 make-&key-descr
		   [when _
			 (? (argument-keyword? _.)
				(copy-def-until-&key _)
				(alet _.
                  (push (? (cons? !)
                           (. !. .!.) ; with default value
                           (. ! !))   ; with itself
                        &keys)
                  (make-&key-descr ._)))]

		 copy-def-until-&key
		   [when _
		     (? (eq '&key _.)
				(make-&key-descr ._)
				(. _. (copy-def-until-&key ._)))])

	(values (copy-def-until-&key def)
            (reverse &keys))))

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

;; Expands argument definition and argument list to an associative list
;; of argument name/value pairs. Argument rest lists start with the
;; &REST keyword. The returned list is grouped into static, optional,
;; keyword and rest values.
;;
;; Supports &REST, &BODY, &OPTIONAL and &KEY with default values.
;; NIL is used when no default value is given.
;; Keywords may occur everywhere in an argument list.
;;
;; When apply-values is NIL, only the expanded argument definition is
;; returned.
;;
;; 'fun' is only used for error messages.
(defun argument-expand-0 (fun adef alst apply-values &optional (no-static nil) (argdefs nil) (key-args nil) (num nil) (rest-arg nil))
  (with (err
		   #'((msg args)
				(throw (+ "; Call of function ~A: ~A~%"
					      "; Argument definition: ~A~%"
						  "; Given arguments: ~A~%")
                       (symbol-name fun)
                       (apply #'format nil msg args)
                       adef
                       alst))
		 exp-static
		   #'((def vals)
			    (& no-static
				   (err "static argument definition after ~A" (list no-static)))
			    (& apply-values (not vals)
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
		        (case def.
				  '&rest     (exp-rest def vals)
				  '&body     (exp-rest def vals)
				  '&optional (exp-optional .def vals)))

		 exp-sub
		   #'((def vals)
			    (& no-static
				   (err "static sublevel argument definition after ~A" (list no-static)))
				(& apply-values (atom vals.)
				   (err "sublist expected for argument ~A" (list num)))
				(%nconc (argument-expand-0 fun def. vals. apply-values)
					    (exp-main .def .vals)))

		 exp-check-too-many
           #'((def vals)
			    (& (not def) vals
				   (err "too many arguments. ~A max, but ~A more given" (list (length argdefs) (length vals)))))

		 exp-main-non-key
		   #'((def vals)
				(exp-check-too-many def vals)
				(?
				  (argument-keyword? def.)    (exp-optional-rest def vals)
				  (not (argument-name? def.)) (exp-sub def vals)
				  (exp-static def vals)))

         exp-main
		   #'((def vals)
			    (++! num)
			    (? (keyword? vals.)
				   (exp-key def vals)
				   (| (exp-check-too-many def vals)
			          (& def (exp-main-non-key def vals))))))

  (with ((a k) (make-&key-alist adef))
	 (= argdefs   a
	    key-args  k
	    num       0
	    no-static nil
	    rest-arg  nil)
	 (%nconc (exp-main argdefs alst)
			 (%nconc key-args
			 		 rest-arg)))))

(defun argument-expand (fun def vals &optional (apply-values t))
  (? apply-values
	 (argument-expand-0 fun def vals apply-values)
	 (carlist (argument-expand-0 fun def vals apply-values))))

(defun argument-expand-names (fun def)
  (argument-expand fun def nil nil))

;;; Tests

(define-test "argument expansion works with simple list"
  ((equal (argument-expand 'test '(a b) '(2 3) t)
	      '((a . 2) (b . 3))))
  t)

(define-test "argument expansion works without :apply-values"
  ((equal (argument-expand-names 'test '(a b))
	      '(a b)))
  t)

(define-test "argument expansion can handle nested lists"
  ((equal (argument-expand 'test '(a (b c) d) '(23 (2 3) 42) t)
	      '((a . 23) (b . 2) (c . 3) (d . 42))))
  t)

(define-test "argument expansion can handle nested lists without :apply-values"
  ((equal (argument-expand-names 'test '(a (b c) d))
	      '(a b c d)))
  t)

(define-test "argument expansion can handle &REST keyword"
  ((equal (argument-expand 'test '(a b &rest c) '(23 5 42 65) t)
		  '((a . 23) (b . 5) (c &rest 42 65))))
  t)

(define-test "argument expansion can handle &REST keyword without :apply-values"
  ((equal (argument-expand-names 'test '(a b c &rest d))
		  '(a b c d)))
  t)

(define-test "argument expansion can handle missing &REST"
  ((equal (argument-expand 'test '(a b &rest c) '(23 5) t)
		  '((a . 23) (b . 5) (c &rest))))
  t)

(define-test "argument expansion can handle missing &REST without :apply-values"
  ((equal (argument-expand-names 'test '(a b &rest c))
		  '(a b c)))
  t)

(define-test "argument expansion can handle &OPTIONAL keyword"
  ((equal (argument-expand 'test '(a b &optional c d) '(23 2 3 42) t)
		  '((a . 23) (b . 2) (c . 3) (d . 42))))
  t)

(define-test "argument expansion can handle &OPTIONAL keyword without :apply-values"
  ((equal (argument-expand-names 'test '(a b &optional c d))
		  '(a b c d)))
  t)

(define-test "argument expansion can handle &OPTIONAL keyword with init forms"
  ((equal (argument-expand 'test '(a b &optional (c 3) (d 42)) '(23 2) t)
		  '((a . 23) (b . 2) (c . 3) (d . 42))))
  t)

(define-test "argument expansion can handle &OPTIONAL keyword with init forms without :apply-values"
  ((equal (argument-expand-names 'test '(a b &optional (c 3) (d 42)))
		  '(a b c d)))
  t)

(define-test "argument expansion can handle &KEY keyword"
  ((equal (argument-expand 'test '(a b &key c d)
								 '(23 2 :c 3 :d 42) t)
		  '((a . 23) (b . 2) (c . 3) (d . 42))))
  t)

(define-test "argument expansion can handle &KEY keyword with overloaded init forms"
  ((equal (argument-expand 'test '(a b &key (c 3) (d 42))
								 '(23 2 :c 5 :d 65) t)
		  '((a . 23) (b . 2) (c . 5) (d . 65))))
  t)

(define-test "argument expansion can handle &KEY keyword without :apply-values"
  ((equal (argument-expand-names 'test '(a b &key c d))
		  '(a b c d)))
  t)

(define-test "argument expansion can handle &OPTIONAL and &KEY keyword with init forms without :apply-values"
  ((equal (argument-expand-names 'test '(a b &optional (c 3) &key (d 42)))
		  '(a b c d)))
  t)

(define-test "argument expansion can handle &OPTIONAL and &KEY keyword with init forms with :apply-values"
  ((equal (argument-expand 'test '(a b &optional (c 3) &key (d 42))
								 '(23 2 3 :d 65) t)
		  '((a . 23) (b . 2) (c . 3) (d . 65))))
  t)

;(define-test "argument expansion can handle &KEY keyword with init forms"
;  ((equal (argument-expand '(a b &key (c 3) (d 42)) '(23 2) t)
;          '(values (a b c d) (23 2 3 42)))))
