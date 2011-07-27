;;;;; TRE compiler
;;;;; Copyright (c) 2005-2011 Sven Klose <pixel@copei.de>

;;; Pass lexical up one step through ghost.

(defun make-lexical-place-expr (fi var)
  `(%vec ,(funinfo-ghost fi)
         ,(funinfo-sym (funinfo-parent fi))
         ,var))

(defun make-lexical-1 (fi var)
  (? (funinfo-in-args-or-env? (funinfo-parent fi) var)
	 (make-lexical-place-expr fi var)
	 (make-lexical-1 (funinfo-parent fi) var)))

(defun make-lexical-0 (fi x)
  (funinfo-setup-lexical-links fi x)
  (let ret (make-lexical-1 fi x)
	`(%vec ,(make-lexical fi .ret.)
		   ,..ret.
		   ,...ret.)))

(defun make-lexical (fi x)
  (? (eq (funinfo-ghost fi) x)
	 (place-expand-atom (funinfo-parent fi) x)
	 (make-lexical-0 fi x)))

(defun place-expand-emit-stackplace (fi x)
  (? (transpiler-stack-locals? *current-transpiler*)
  	 `(%stack ,(funinfo-sym fi) ,x)
	 x))

(defun place-expand-atom (fi x)
  (?
	(not fi)
	  (progn
		(print x)
	    (error "place-expand-atom: no funinfo"))

	(or (not x)
		(number? x)
		(string? x)
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

	(not (transpiler-lambda-export? *current-transpiler*))
      x

	; Emit stack place.
	(and (transpiler-stack-locals? *current-transpiler*)
         (funinfo-in-env? fi x))
      (place-expand-emit-stackplace fi x)

    (or (funinfo-in-args-or-env? fi x)
        (and (transpiler-place-expand-ignore-toplevel-funinfo? *current-transpiler*)
             (funinfo-in-toplevel-env? fi x)))
	  x

    ; Emit lexical place (outside the function).
    (make-lexical fi x)))

(defun place-expand-fun (fi name fun-expr)
  (let fi (get-lambda-funinfo fun-expr)
	(unless fi
	  (print fun-expr)
	  (error "place-expand-fun: no funinfo"))
    `(function
	   ,@(awhen name
		   (list !))
	   (,@(lambda-head fun-expr)
  	        ,@(place-expand-0 fi (lambda-body fun-expr))))))

(defun place-expand-setter (fi x)
  (let p (place-expand-0 fi (%setq-place x))
    `(%set-vec ,.p. ,..p. ,...p. ,(place-expand-0 fi (%setq-value x)))))

(define-tree-filter place-expand-0 (fi x)
  (not fi) (error "place-expand-0: no funinfo")
  (atom x) (place-expand-atom fi x)
  (or (%quote? x)
	  (%transpiler-native? x)
	  (%var? x)) x
  (named-lambda? x) (place-expand-fun fi .x. ..x.)
  (lambda? x) (place-expand-fun fi nil x) ; XXX Add variables to ignore in subfunctions.
  (and (%setq? x)
       (%vec? (place-expand-0 fi (%setq-place x)))) (place-expand-setter fi x)
  (and (%set-atom-fun? x)
       (%vec? (place-expand-0 fi (%setq-place x)))) (place-expand-setter fi x)
  (%%funref? x) `(%%funref ,.x. ,(place-expand-0 fi ..x.))
  (%setq-atom-value? x) `(%setq-atom-value ,.x. ,(place-expand-0 fi ..x.))
  (%slot-value? x) `(%slot-value ,(place-expand-0 fi .x.) ,..x.))

(defun place-expand (x)
  (place-expand-0 (transpiler-global-funinfo *current-transpiler*) x))

(defun place-expand-funref-lexical (fi)
  (place-expand-0 (funinfo-parent fi)
                  (funinfo-lexical (funinfo-parent fi))))
