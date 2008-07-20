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
		   #'((x)
		        (when x
				  (if (argument-keyword? (first x))
					  (rec x)
					  ; Turn keyword definition into ACONS.
					  (and (setf argument-exp-sort-key (cons (if (consp (first x))
											   (cons (first (first x)) (second (first x))) ; with default value
											   (list (first x))) ; without default value
										   argument-exp-sort-key))
						   (rec2 (cdr x))))))

		 ; Copy argument definition until &KEY.
		 rec
		   #'((x)
		        (when x
		          (if (eq '&key (first x))
					  (rec2 (cdr x))
					  (cons (first x) (rec (cdr x)))))))

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
				(if (consp (first def))
					(first (first def))
					(first def)))

		 get-default
		   #'((def)
				(when (consp (first def))
				  (second (first def))))

		 get-value
		   #'((def vals)
				(if (consp vals)
					(first vals)
					(if (consp (first def))
						(second (first def))
						(first def))))

		 check-val
		   #'((vals)
			    (and apply-values (endp vals)
				     (err "argument ~A missing" num)))

		 exp-static
		   #'((def vals)
			    (when no-static
				  (err "static argument definition after ~A" no-static))
				(check-val vals)
				(cons (cons (first def) (first vals))
					  (exp-main (cdr def) (cdr vals))))

		 exp-optional
		   #'((def vals)
				(when (argument-keyword? (first def))
				  (err "Keyword ~A after &OPTIONAL" (first def)))
				(setf no-static '&optional)
				(cons (cons (get-name def) (get-value def vals))
					  (if (argument-list-keyword? (second def))
					  	  (exp-main (cdr def) (cdr vals))
						  (when (cdr def)
						    (exp-optional (cdr def) (cdr vals))))))

		 exp-key
		   #'((def vals)
			    (with  (w (make-symbol (symbol-name (first vals)))
			    		k (assoc w key-args))
				  (if k
			          (progn
						(rplacd k (second vals)) ; check if key-value exists.
						(exp-main def (cddr vals)))
					  (exp-main-non-key def vals))))

		 exp-rest
		   #'((def vals)
				(setf no-static '&rest)
  			    (setf rest-arg (list (cons (first def)
										   (cons '&rest
												 vals))))
			    nil)

         exp-optional-rest
		   #'((def vals)
  			      (case (first def)
				    ('&rest		(exp-rest (cdr def) vals))
				    ('&body		(exp-rest (cdr def) vals))
				    ('&optional	(exp-optional (cdr def) vals))))

		 exp-sub
		   #'((def vals)
			    (when no-static
				  (err "static sublevel argument definition after ~A" no-static))
				(and apply-values (not (consp (first vals)))
					 (err "sublist expected for argument ~A" num))
				(nconc (argument-expand2 fun (first def) (first vals) apply-values)
					   (exp-main (cdr def) (cdr vals))))

		 exp-check-too-many
           #'((def vals)
			    (and (not def) vals
				     (err "too many arguments. ~A max, but ~A more given"
						    (length argdefs) (length vals))))

		 exp-main-non-key
		   #'((def vals)
				(exp-check-too-many def vals)
				(if (argument-keyword? (first def))
				    (exp-optional-rest def vals)
				    (if (consp (first def))
				        (exp-sub def vals)
				        (exp-static def vals))))

         exp-main
		   #'((def vals)
			    (incf num)
			    (if (keywordp (first vals))
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

(defun argument-expand (fun def vals apply-values)
  (funcall (if apply-values
			   #'identity
			   #'carlist)
		   (argument-expand2 fun def vals apply-values)))

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
