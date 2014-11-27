;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun carlist (x) (mapcar #'car x))

(defun argument-rest-keyword? (x)     (in? x '&rest '&body))
(defun argument-keyword? (x)          (in? x '&rest '&body '&optional '&key))
(defun argument-name? (x)             (atom x))
(defun argument-name (x)              x)
(defun argument-def-without-type (x)  x)

(defun error-arguments-missing (fun args)
  (error "Arguments ~A missing for function ~A." fun args))

(defun error-too-many-arguments (fun args)
  (error "Too many arguments ~A for function ~A." args fun))

(defun error-&rest-has-value (fun)
  (error "In function ~A: &REST cannot have a value." fun))

(defun make-&key-alist (def)
  (let ((keys nil))
    (labels ((make-&key-descr (_)
               (when _
			     (? (argument-keyword? (car _))
				    (copy-def-until-&key _)
				    (alet (car _)
                      (push (? (cons? !)
                               (cons (car !) (cadr !)) ; with default value
                               (cons ! !))   ; with itself
                            keys)
                      (make-&key-descr (cdr _))))))

		     (copy-def-until-&key (_)
		       (when _
		         (? (eq '&key (car _))
				    (make-&key-descr (cdr _))
				    (cons (car _) (copy-def-until-&key (cdr _)))))))

	(values (copy-def-until-&key def)
            (reverse keys)))))

(defun argdef-get-name (x)
  (? (cons? x)
     (car x)
     x))

(defun argdef-get-default (x)
  (? (cons? x)
     (cadr x)
     x))

(defun argdef-get-value (defs vals)
  (?
    (cons? vals)        (car vals)
    (cons? (car defs))  (cadar defs)
    (car defs)))

(defun argument-expand-0 (fun adef alst apply-values? concatenate-sublists?)
  (multiple-value-bind (a k) (make-&key-alist adef)
    (let ((argdefs    a)
	      (key-args   k)
	      (num        0)
	      (no-static  nil)
	      (rest-arg   nil))
      (labels ((err (msg args)
				 (error "; Call of function ~A: ~A~%; Argument definition: ~A~%; Given arguments: ~A~%"
                        (symbol-name fun)
                        (apply #'format nil msg args)
                        adef
                        alst))
		       (exp-static (def vals)
			     (and no-static
				      (err "static argument definition after ~A" (list no-static)))
			     (and apply-values? (not vals)
				      (err "argument ~A missing" (list num)))
				 (cons (cons (argdef-get-name (car def)) (car vals))
                       (exp-main (cdr def) (cdr vals))))

		       (exp-optional (def vals)
				 (and (argument-keyword? (car def))
				      (err "Keyword ~A after &OPTIONAL" (list (car def))))
				 (setf no-static '&optional)
				 (cons (cons (argdef-get-name (car def))
				             (argdef-get-value def vals))
				       (?
					     (argument-keyword? (cadr def))  (exp-main (cdr def) (cdr vals))
					     (cdr def)                       (exp-optional (cdr def) (cdr vals))
					     (exp-main (cdr def) (cdr vals)))))

		       (exp-key (def vals)
			     (let ((k (assoc ($ (car vals)) key-args :test #'eq)))
				   (? k
			          (alet vals
					    (rplacd k (cadr !)) ; check if key-value exists.
					    (exp-main def (cddr !)))
					  (exp-main-non-key def vals))))

		       (exp-rest (def vals)
				 (setf no-static '&rest)
  			     (setf rest-arg (list (cons (argdef-get-name (cadr def))
                                            (cons (car def) vals))))
			     nil)

               (exp-optional-rest (def vals)
		         (alet (car def)
				   (?
                     (eq ! '&rest)     (exp-rest def vals)
                     (eq ! '&body)     (exp-rest def vals)
                     (eq ! '&optional) (exp-optional (cdr def) vals))))

		       (exp-sub (def vals)
			     (and no-static
				      (err "static sublevel argument definition after ~A" (list no-static)))
				 (and apply-values? (atom (car vals))
				      (err "sublist expected for argument ~A" (list num)))
                 (? concatenate-sublists?
				    (%nconc (argument-expand-0 fun (car def) (car vals) apply-values? concatenate-sublists?)
					        (exp-main (cdr def) (cdr vals)))
				    (cons (cons nil (argument-expand-0 fun (car def) (car vals) apply-values? concatenate-sublists?))
					      (exp-main (cdr def) (cdr vals)))))

		       (exp-check-too-many (def vals)
			    (and (not def) vals
				     (err "too many arguments. ~A max, but ~A more given" (list (length argdefs) (length vals)))))

		       (exp-main-non-key (def vals)
				 (exp-check-too-many def vals)
				 (?
				   (argument-keyword? (car def))     (exp-optional-rest def vals)
				   (not (argument-name? (car def)))  (exp-sub def vals)
				   (exp-static def vals)))

               (exp-main (def vals)
			     (setf num (+ 1 num))
			     (? (keywordp (car vals))
				    (exp-key def vals)
				    (or (exp-check-too-many def vals)
			            (and def
                             (exp-main-non-key def vals))))))
	 (%nconc (exp-main argdefs alst)
			 (%nconc key-args rest-arg))))))

(defun argument-expand (fun def vals &key (apply-values? t) (concatenate-sublists? t))
  (? apply-values?
	 (argument-expand-0 fun def vals apply-values? concatenate-sublists?)
	 (carlist (argument-expand-0 fun def vals apply-values? concatenate-sublists?))))

(defun argument-expand-names (fun def)
  (argument-expand fun def nil :apply-values? nil))
