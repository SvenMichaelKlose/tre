;;;;; tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

(defun funinfo-var-ghost (fi var)
  (? (funinfo-arg-or-var? (funinfo-parent fi) var)
     (funinfo-ghost fi)
	 (funinfo-var-ghost (funinfo-parent fi) var)))

(defun link-funinfos-make-lexicals-0 (fi x)
  (funinfo-setup-lexical-links fi x)
  (link-funinfos-atom fi (link-funinfos-make-lexicals fi (funinfo-var-ghost fi x))))

(defun link-funinfos-make-lexicals (fi x)
  (? (eq x (funinfo-ghost fi))
	 (link-funinfos-atom (funinfo-parent fi) x)
	 (link-funinfos-make-lexicals-0 fi x)))

(defun link-funinfos-emit-stackplace (fi x)
  `(%stack ,(funinfo-sym fi) ,x))

(defun link-funinfos-atom (fi x)
  (?
    (| (not x)
       (number? x)
       (string? x)
       (not (funinfo-var-or-lexical? fi x))
       (funinfo-toplevel-var? fi x)
       (& (transpiler-stack-locals? *current-transpiler*)
          (eq x (funinfo-lexical fi))))
      nil

    (& (not (eq x (funinfo-lexical fi)))
       (funinfo-lexical? fi x))
      (link-funinfos-atom fi (funinfo-lexical fi))

    (| (& (transpiler-stack-locals? *current-transpiler*)
          (| (& (transpiler-arguments-on-stack? *current-transpiler*)
                (funinfo-arg? fi x))
             (funinfo-var? fi x)))
       (funinfo-arg-or-var? fi x))
      nil

    (link-funinfos-make-lexicals fi x)))

(defun link-funinfos-fun (fi name fun-expr)
  (link-funinfos-0 (get-lambda-funinfo fun-expr) (lambda-body fun-expr)))

(defun link-funinfos-setter (fi x)
  (link-funinfos-0 fi (%setq-place x))
  (link-funinfos-0 fi (%setq-value x)))

(define-tree-filter link-funinfos-0 (fi x)
  (not fi)              (error "link-funinfos-0: no funinfo")
  (atom x)              (link-funinfos-atom fi x)
  (| (%quote? x)
     (%transpiler-native? x)
     (%var? x))
                        nil
  (named-lambda? x)     (link-funinfos-fun fi .x. ..x.)
  (lambda? x)           (link-funinfos-fun fi nil x)
  (& (| (%setq? x)
        (%set-atom-fun? x))
     (%vec? (link-funinfos-0 fi (%setq-place x))))
                        (link-funinfos-setter fi x)
  (%%closure? x)        (link-funinfos-0 fi ..x.)
  (%setq-atom-value? x) (link-funinfos-0 fi ..x.)
  (%slot-value? x)      (link-funinfos-0 fi .x.)
  (%stackarg? x)        x)

(defun link-funinfos (x)
  (link-funinfos-0 (transpiler-global-funinfo *current-transpiler*) x)
  x)

(defun link-funinfos-funref-lexical (fi)
  (alet (funinfo-parent fi)
    (link-funinfos-0 ! (funinfo-lexical !))))
