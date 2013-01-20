;;;;; tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

(defun make-lexical-place-expr (fi var)
  `(%vec ,(funinfo-ghost fi)
         ,(funinfo-sym (funinfo-parent fi))
         ,var))

(defun make-lexical-1 (fi var)
  (? (funinfo-arg-or-var? (funinfo-parent fi) var)
	 (make-lexical-place-expr fi var)
	 (make-lexical-1 (funinfo-parent fi) var)))

(defun make-lexical-0 (fi x)
  (funinfo-setup-lexical-links fi x)
  (let ret (make-lexical-1 fi x)
	`(%vec ,(place-expand-atom fi (make-lexical fi .ret.))
		   ,..ret.
		   ,...ret.)))

(defun make-lexical (fi x)
  (? (eq x (funinfo-ghost fi))
	 (place-expand-atom (funinfo-parent fi) x)
	 (make-lexical-0 fi x)))

(defun place-expand-emit-stackplace (fi x)
  `(%stack ,(funinfo-sym fi) ,x))

(defun place-expand-atom (fi x)
  (?
    (not fi)
      (progn
        (print x)
        (error "place-expand-atom: no funinfo"))

    (| (not x)
       (number? x)
       (string? x)
       (not (transpiler-lambda-export? *current-transpiler*))
       (not (funinfo-var-or-lexical? fi x))
       (funinfo-toplevel-var? fi x))
      x

    (& (transpiler-stack-locals? *current-transpiler*)
       (eq x (funinfo-lexical fi)))
      (place-expand-emit-stackplace fi x)

    (& (not (eq x (funinfo-lexical fi)))
       (funinfo-lexical? fi x))
      `(%vec ,(place-expand-atom fi (funinfo-lexical fi))
             ,(funinfo-sym fi)
             ,x)

    (& (transpiler-stack-locals? *current-transpiler*)
       (| (& (transpiler-arguments-on-stack? *current-transpiler*)
             (funinfo-arg? fi x))
          (funinfo-var? fi x)))
       (place-expand-emit-stackplace fi x)

    (funinfo-arg-or-var? fi x)
      x

    (make-lexical fi x)))

(defun place-expand-fun (fi name fun-expr)
  (let fi (get-lambda-funinfo fun-expr)
	(unless fi
	  (print fun-expr)
	  (error "place-expand-fun: no funinfo"))
    `(function
	   ,@(awhen name (list !))
	   (,@(lambda-head fun-expr)
  	        ,@(place-expand-0 fi (lambda-body fun-expr))))))

(defun place-expand-setter (fi x)
  (let p (place-expand-0 fi (%setq-place x))
    `(%set-vec ,.p. ,..p. ,...p. ,(place-expand-0 fi (%setq-value x)))))

(define-tree-filter place-expand-0 (fi x)
  (not fi)              (error "place-expand-0: no funinfo")
  (atom x)              (place-expand-atom fi x)
  (| (%quote? x)
     (%transpiler-native? x)
     (%var? x))
                        x
  (named-lambda? x)     (place-expand-fun fi .x. ..x.)
  (lambda? x)           (place-expand-fun fi nil x)
  (& (%setq? x)
     (%vec? (place-expand-0 fi (%setq-place x))))
                        (place-expand-setter fi x)
  (& (%set-atom-fun? x)
     (%vec? (place-expand-0 fi (%setq-place x))))
                        (place-expand-setter fi x)
  (%%closure? x)        `(%%closure ,.x. ,(place-expand-0 fi ..x.))
  (%setq-atom-value? x) `(%setq-atom-value ,.x. ,(place-expand-0 fi ..x.))
  (%slot-value? x)      `(%slot-value ,(place-expand-0 fi .x.) ,..x.)
  (%stackarg? x)        x)

(defun place-expand (x)
  (place-expand-0 (transpiler-global-funinfo *current-transpiler*) x))

(defun place-expand-closure-lexical (fi)
  (alet (funinfo-parent fi)
    (place-expand-0 ! (funinfo-lexical !))))
