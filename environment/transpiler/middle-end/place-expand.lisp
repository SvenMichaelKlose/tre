;;;;; TRE compiler
;;;;; Copyright (c) 2005-2010 Sven Klose <pixel@copei.de>

;;; Pass lexical up one step through ghost.

(defun make-lexical-place-expr (fi var)
  `(%vec ,(funinfo-ghost fi)
         ,(funinfo-sym (funinfo-parent fi))
         ,var))

(defun make-lexical-1 (fi var)
  (if (funinfo-in-args-or-env? (funinfo-parent fi) var)
	  (make-lexical-place-expr fi var)
	  (make-lexical-1 (funinfo-parent fi) var)))

(defun make-lexical-0 (fi x)
  (funinfo-setup-lexical-links fi x)
  (let ret (make-lexical-1 fi x)
	`(%vec ,(make-lexical fi .ret.)
		   ,..ret.
		   ,...ret.)))

(defun make-lexical (fi x)
  (if (eq (funinfo-ghost fi) x)
	  (place-expand-atom (funinfo-parent fi) x)
	  (make-lexical-0 fi x)))

(defun place-expand-emit-stackplace (fi x)
  (if (transpiler-stack-locals? *current-transpiler*)
  	  `(%stack ,(funinfo-sym fi)
			   ,x)
	  x))

(defun place-expand-atom (fi x)
  (if
	(not fi)
	  (error "place-assign: no funinfo for ~A" x)

	(or (not x)
		(numberp x)
		(stringp x)
		(not (funinfo-in-this-or-parent-env? fi x)))
	  x

	(and (transpiler-stack-locals? *current-transpiler*)
		 (eq x (funinfo-lexical fi)))
	  (place-expand-emit-stackplace fi x)

	; Emit lexical place, except the lexical array itself (it can
	; self-reference for child functions).
	(and (not (eq x (funinfo-lexical fi)))
		 (funinfo-lexical? fi x))
	  `(%vec ,(place-expand-atom fi (funinfo-lexical fi))
			 ,(funinfo-sym fi)
			 ,x)

	(or (funinfo-arg? fi x)
	    (and (not (transpiler-stack-locals? *current-transpiler*))
			 (eq x (funinfo-lexical fi))))
	  x

	; Emit stack place.
	(funinfo-in-env? fi x)
	  (place-expand-emit-stackplace fi x)

	; Emit lexical place (outside the function).
	(make-lexical fi x)))

(defun place-expand-0 (fi x)
  (if
	(atom x)
	  (place-expand-atom fi x)

	(or (%quote? x)
		(%transpiler-native? x)
		(%stack? x)
		(%vec? x)
		(%var? x))
	  x

	(lambda? x) ; XXX Add variables to ignore in subfunctions.
      `#'(,@(lambda-head x)
		     ,@(place-expand-0 (get-lambda-funinfo x)
							   (lambda-body x)))

    (%slot-value? x)
      `(%slot-value ,(place-expand-0 fi .x.)
					,..x.)

    (cons (place-expand-0 fi x.)
		  (place-expand-0 fi .x))))

(defun place-expand (x)
  (if
	(atom x)
	  x

	(named-function-expr? x)
	  `(function ,.x.
	  			 (,@(lambda-head ..x.)
	          	 	  ,@(place-expand-0 (get-lambda-funinfo ..x.)
									    (lambda-body ..x.))))

	(lambda? x)
	  `#'(,@(lambda-head x)
	          ,@(place-expand-0 (get-lambda-funinfo x)
								(lambda-body x)))
	(cons (place-expand x.)
		  (place-expand .x))))

(defun place-expand-funref-lexical (fi)
  (place-expand-0 (funinfo-parent fi)
                  (funinfo-lexical (funinfo-parent fi))))
