;;;;; tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

(defun make-lexical-place-expr (fi var)
  (funinfo-add-free-var fi var)
  `(%vec ,(funinfo-scope-arg fi)
         ,(funinfo-name (funinfo-parent fi))
         ,var))

(defun make-lexical-1 (fi var)
  (? (funinfo-arg-or-var? (funinfo-parent fi) var)
	 (make-lexical-place-expr fi var)
	 (make-lexical-1 (funinfo-parent fi) var)))

(defun make-lexical-0 (fi x)
  (funinfo-setup-scope fi x)
  (let ret (make-lexical-1 fi x)
	`(%vec ,(place-expand-atom fi (make-lexical fi .ret.))
		   ,..ret.
		   ,...ret.)))

(defun make-lexical (fi x)
  (? (eq x (funinfo-scope-arg fi))
	 (place-expand-atom (funinfo-parent fi) x)
	 (make-lexical-0 fi x)))

(defun place-expand-emit-stackplace (fi x)
  `(%stack ,(funinfo-name fi) ,x))

(defun place-expand-atom (fi x)
  (?
    (| (constant-literal? x)
       (not (funinfo-find fi x)
            (funinfo-global-variable? fi x)))
      x

    (& (transpiler-stack-locals? *transpiler*)
       (eq x (funinfo-scope fi)))
      (place-expand-emit-stackplace fi x)

    (& (not (eq x (funinfo-scope fi)))
       (funinfo-scoped-var? fi x))
      `(%vec ,(place-expand-atom fi (funinfo-scope fi))
             ,(funinfo-name fi)
             ,x)

    (& (transpiler-stack-locals? *transpiler*)
       (funinfo-var? fi x))
      (place-expand-emit-stackplace fi x)

    (funinfo-arg-or-var? fi x)
      x

    (funinfo-global-variable? fi x)
      `(%global ,x)

    (make-lexical fi x)))

(defun place-expand-fun (x)
  (copy-lambda x :body (place-expand-0 (get-lambda-funinfo x) (lambda-body x))))

(defun place-expand-setter (fi x)
  (let p (place-expand-0 fi (%=-place x))
    `(%set-vec ,.p. ,..p. ,...p. ,(place-expand-0 fi (%=-value x)))))

(define-tree-filter place-expand-0 (fi x)
  (atom x)              (place-expand-atom fi x)
  (| (%quote? x)
     (%%native? x)
     (%var? x))         x
  (named-lambda? x)     (place-expand-fun x)
  (& (%=? x)
     (%vec? (place-expand-0 fi (%=-place x))))
                        (place-expand-setter fi x)
  (& (%set-atom-fun? x)
     (%vec? (place-expand-0 fi (%=-place x))))
                        (place-expand-setter fi x)
  (%%closure? x)        x
  (%slot-value? x)      `(%slot-value ,(place-expand-0 fi .x.) ,..x.)
  (%stackarg? x)        x)

(defun place-expand (x)
  (place-expand-0 (transpiler-global-funinfo *transpiler*) x))

(defun fake-place-expand (x)
  (place-expand x)
  x)

(defun place-expand-closure-scope (fi)
  (alet (funinfo-parent fi)
    (place-expand-0 ! (funinfo-scope !))))
