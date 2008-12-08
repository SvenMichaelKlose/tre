;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Argument expander.

(defun argument-keyword? (x)
  (in? x '&rest '&body '&optional '&key))

(defun argument-list-keyword? (x)
  (or (argument-keyword? x)
      (keywordp x)))

;; We want keywords to be legal all across a level.
;; Make an extra keyword definition list, so they can be found.
(defvar argument-exp-sort-key)
(defun argument-exp-sort (def)
  (with (; Copy &KEY definitions.
		 rec2
		   (fn
		     (when _
			   (if (argument-keyword? _.)
				   (rec _)
				   ; Turn keyword definition into ACONS.
				   (and (setf argument-exp-sort-key
							  (cons (if (consp _.)
										(cons (first _.)
											  (second _.)) ; with default value
										(list _.)) ; without default value
									argument-exp-sort-key))
						(rec2 ._)))))

		 ; Copy argument definition until &KEY.
		 rec
		   (fn
		     (when _
		       (if (eq '&key _.)
				   (rec2 ._)
				   (cons _. (rec ._))))))

	(setf argument-exp-sort-key nil)
	(values (rec def) (reverse argument-exp-sort-key))))

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
(defun argument-expand2 (fun adef alst apply-values &optional no-static argdefs key-args num rest-arg)
  (with (err
		   #'((msg &rest args)
				(apply #'error
					   (string-concat
						 (format nil "Call of function ~A:~%" (symbol-name fun))
						 (format nil "Argument definition: ~A~%" adef)
						 (format nil "Given arguments: ~A~%" alst)
						 msg)
					   args))
		 get-name
		   #'((def)
				(if (consp def.)
					(first def.)
					def.))

		 get-default
		   #'((def)
				(when (consp def.)
				  (second def.)))

		 get-value
		   #'((def vals)
				(if (consp vals)
					vals.
					(if (consp def.)
						(second def.)
						def.)))

		 check-val
		   #'((vals)
			    (and apply-values (endp vals)
				     (err "argument ~A missing" num)))

		 exp-static
		   #'((def vals)
			    (when no-static
				  (err "static argument definition after ~A" no-static))
				(check-val vals)
				(cons (cons def. vals.)
					  (exp-main .def .vals)))

		 exp-optional
		   #'((def vals)
				(when (argument-keyword? def.)
				  (err "Keyword ~A after &OPTIONAL" def.))
				(setf no-static '&optional)
				(cons (cons (get-name def) (get-value def vals))
					  (if (argument-list-keyword? (second def))
					  	  (exp-main .def .vals)
						  (when .def
						    (exp-optional .def .vals)))))

		 exp-key
		   #'((def vals)
			    (with  (w (make-symbol (symbol-name vals.))
			    		k (assoc w key-args))
				  (if k
			          (progn
						(rplacd k (second vals)) ; check if key-value exists.
						(exp-main def (cddr vals)))
					  (exp-main-non-key def vals))))

		 exp-rest
		   #'((def vals)
				(setf no-static '&rest)
  			    (setf rest-arg (list (cons (get-name def)
										   (cons '&rest
												 (or vals
													 (get-default def))))))
			    nil)

         exp-optional-rest
		   #'((def vals)
  			      (case def.
				    ('&rest		(exp-rest .def vals))
				    ('&body		(exp-rest .def vals))
				    ('&optional	(exp-optional .def vals))))

		 exp-sub
		   #'((def vals)
			    (when no-static
				  (err "static sublevel argument definition after ~A" no-static))
				(and apply-values (not (consp vals.))
					 (err "sublist expected for argument ~A" num))
				(nconc (argument-expand2 fun def. vals. apply-values)
					   (exp-main .def .vals)))

		 exp-check-too-many
           #'((def vals)
			    (and (not def) vals
				     (err "too many arguments. ~A max, but ~A more given"
						    (length argdefs) (length vals))))

		 exp-main-non-key
		   #'((def vals)
				(exp-check-too-many def vals)
				(if (argument-keyword? def.)
				    (exp-optional-rest def vals)
				    (if (consp def.)
				        (exp-sub def vals)
				        (exp-static def vals))))

         exp-main
		   #'((def vals)
			    (incf num)
			    (if (keywordp vals.)
				    (exp-key def vals)
					(or (exp-check-too-many def vals)
			        	(when def
					      (exp-main-non-key def vals))))))

  (with ((a k) (argument-exp-sort adef))
	 (setf argdefs a
		   key-args k
		   num 0
		   no-static nil
		   rest-arg nil)
	 (nconc (exp-main argdefs alst)
			 key-args
			 rest-arg))))

(defun argument-expand (fun def vals &optional (apply-values t))
  (funcall (if apply-values
			   #'identity
			   #'carlist)
		   (argument-expand2 fun def vals apply-values)))

(defun argument-expand-names (fun def)
  (argument-expand fun def nil nil))

(defun %argument-expand-rest (args)
  (when args
    `(cons ,args.
           ,(%argument-expand-rest .args))))

(defun argument-expand-compiled-values (fun def vals)
  (mapcar #'((x)
               (if (and (consp x)
                        (eq '&rest x.))
                   (%argument-expand-rest .x)
                   x))
          (cdrlist (argument-expand fun def vals t))))

;;; Tests

(define-test "argument expansion basically works"
  ((equal (argument-expand 'test '(a b) '(2 3) t)
	      '((a . 2) (b . 3))))
  t)

(define-test "argument expansion basically works without apply-values"
  ((equal (argument-expand 'test '(a b) nil nil)
	      '(a b)))
  t)

(define-test "argument expansion can handle nested lists"
  ((equal (argument-expand 'test '(a (b c) d) '(23 (2 3) 42) t)
	    '((a . 23) (b . 2) (c . 3) (d . 42))))
  t)

(define-test "argument expansion can handle nested lists without apply-values"
  ((equal (argument-expand 'test '(a (b c) d) nil nil)
	    '(a b c d)))
  t)

(define-test "argument expansion can handle &REST keyword"
  ((equal (argument-expand 'test '(a b &rest c) '(23 5 42 65) t)
	  '((a . 23) (b . 5) (c &rest 42 65))))
  t)

(define-test "argument expansion can handle &REST keyword without apply-values"
  ((equal (argument-expand 'test '(a b c &rest d) nil nil)
	    '(a b c d)))
  t)

(define-test "argument expansion can handle missing &REST"
  ((equal (argument-expand 'test '(a b &rest c) '(23 5) t)
	  '((a . 23) (b . 5) (c &rest))))
  t)

(define-test "argument expansion can handle missing &REST without apply-values"
  ((equal (argument-expand 'test '(a b &rest c) '(23 5) nil)
	  '(a b c)))
  t)

(define-test "argument expansion can handle &OPTIONAL keyword"
  ((equal (argument-expand 'test '(a b &optional c d) '(23 2 3 42) t)
	  '((a . 23) (b . 2) (c . 3) (d . 42))))
  t)

(define-test "argument expansion can handle &OPTIONAL keyword without apply-values"
  ((equal (argument-expand 'test '(a b &optional c d) nil nil)
	    '(a b c d)))
  t)

(define-test "argument expansion can handle &OPTIONAL keyword with init forms"
  ((equal (argument-expand 'test '(a b &optional (c 3) (d 42)) '(23 2) t)
	  '((a . 23) (b . 2) (c . 3) (d . 42))))
  t)

(define-test "argument expansion can handle &OPTIONAL keyword with init forms without apply-values"
  ((equal (argument-expand 'test '(a b &optional (c 3) (d 42)) nil nil)
	    '(a b c d)))
  t)

(define-test "argument expansion can handle &KEY keyword"
  ((equal (argument-expand 'test '(a b &key c d) '(23 2 :c 3 :d 42) t)
	  '((a . 23) (b . 2) (c . 3) (d . 42))))
  t)

(define-test "argument expansion can handle &KEY keyword without apply-values"
  ((equal (argument-expand 'test '(a b &key c d) nil nil)
	    '(a b c d)))
  t)

;(define-test "argument expansion can handle &KEY keyword with init forms"
;  ((equal (argument-expand '(a b &key (c 3) (d 42)) '(23 2) t)
;          '(values (a b c d) (23 2 3 42))))
