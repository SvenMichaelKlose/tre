(defun make-scope-place-expr (fi x)
  (funinfo-add-free-var fi x)
  `(%vec ,(funinfo-scope-arg fi)
         ,(funinfo-name (funinfo-parent fi))
         ,x))

(defun make-scope-place-1 (fi x)
  (? (funinfo-arg-or-var? (funinfo-parent fi) x)
	 (make-scope-place-expr fi x)
	 (make-scope-place-1 (funinfo-parent fi) x)))

(defun make-scope-place (fi x)
  (? (funinfo-scope-arg? fi x)
	 x
     {(funinfo-setup-scope fi x)
      (alet (make-scope-place-1 fi x)
	    `(%vec ,(place-expand-atom fi (make-scope-place fi .!.))
               ,..!.
               ,...!.))}))

(defun place-expand-emit-stackplace (fi x)
  `(%stack ,(funinfo-name fi) ,x))

(defun place-expand-atom (fi x)
  (?
    (| (constant-literal? x)
       (not (funinfo-find fi x)
            (funinfo-global-variable? fi x)))
      x

    (& (stack-locals?)
       (eq x (funinfo-scope fi)))
      (place-expand-emit-stackplace fi x)

    (& (not (eq x (funinfo-scope fi)))
       (funinfo-scoped-var? fi x))
      `(%vec ,(place-expand-atom fi (funinfo-scope fi))
             ,(funinfo-name fi)
             ,x)

    (| (& (stack-locals?)
          (funinfo-var? fi x))
       (& (arguments-on-stack?)
          (funinfo-arg? fi x)))
      (place-expand-emit-stackplace fi x)

    (funinfo-arg-or-var? fi x)
      x

    (funinfo-global-variable? fi x)
      `(%global ,x)

    (make-scope-place fi x)))

(defun place-expand-fun (x)
  (copy-lambda x :body (place-expand-0 (get-lambda-funinfo x) (lambda-body x))))

(defun place-expand-setter (fi x)
  (let p (place-expand-0 fi .x.)
    `(%set-vec ,.p. ,..p. ,...p. ,(place-expand-0 fi ..x.))))

(define-tree-filter place-expand-0 (fi x)
  (atom x)              (place-expand-atom fi x)
  (| (quote? x)
     (%%native? x)
     (%var? x))         x
  (named-lambda? x)     (place-expand-fun x)
  (& (%=? x)
     (%vec? (place-expand-0 fi .x.)))
                        (place-expand-setter fi x)
  (& (%set-local-fun? x)
     (%vec? (place-expand-0 fi .x.)))
                        (place-expand-setter fi x)
  (%closure? x)         x
  (%slot-value? x)      `(%slot-value ,(place-expand-0 fi .x.) ,..x.)
  (%stackarg? x)        x)

(defun place-expand (x)
  (place-expand-0 (global-funinfo) x))

(defun place-expand-closure-scope (fi)
  (alet (funinfo-parent fi)
    (place-expand-0 ! (funinfo-scope !))))
