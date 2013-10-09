;;;;; tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

;;;; INLINING

(defun lambda-expand-make-inline-body (stack-places values body)
  `(%%block
	 ,@(mapcar #'((stack-place init-value)
				    `(%setq ,stack-place ,init-value))
			   stack-places values)
     ,@body))

(defun lambda-call-embed (fi lambda-call)
  (with-lambda-call (args vals body lambda-call)
    (with ((a v) (assoc-splice (argument-expand 'dummy-in-lambda-call-embed args vals)))
      (funinfo-var-add-many fi a)
      (lambda-expand-tree fi (lambda-expand-make-inline-body a v body)))))


;;;; EXPORT

(define-gensym-generator closure-name ~closure-)

(defun lambda-export (fi x)
  (with (name   (closure-name)
         args   (lambda-args x)
         body   (lambda-body x)
         new-fi (create-funinfo :name   name
                                :args   args
                                :body   body
                                :parent fi
                                :cps?   (transpiler-cps-transformation? *transpiler*)))
    (funinfo-make-ghost new-fi)
    (transpiler-add-exported-closure *transpiler* `((defun ,name ,(funinfo-argdef new-fi) ,@body)))
    `(%%closure ,name)))


;;;; PASSTHROUGH

(defun lambda-expand-tree-unexported-lambda (fi x)
  (!? (get-funinfo (lambda-name x))
      (copy-lambda x :body (lambda-expand-tree-0 ! (lambda-body x)))
      (with (name   (| (lambda-name x)
                       (funinfo-sym))
             new-fi (create-funinfo :name   name
                                    :args   (lambda-args x)
                                    :body   (lambda-body x)
                                    :parent fi
                                    :cps?   (transpiler-cps-transformation? *transpiler*)))
        (funinfo-var-add fi name)
        (copy-lambda x :name name :body (lambda-expand-tree-0 new-fi (lambda-body x))))))


;;;; TOPLEVEL

(defun lambda-expand-tree-cons (fi x)
  (& (%set-atom-fun? x)
     (lambda? ..x.)
     (funinfo-add-local-function-args fi .x. (lambda-args ..x.)))
  (?
    (lambda-call? x)  (lambda-call-embed fi x)
    (lambda? x)       (? (& (transpiler-lambda-export? *transpiler*)
                            (not (eq fi (transpiler-global-funinfo *transpiler*))))
                         (lambda-export fi x)
                         (lambda-expand-tree-unexported-lambda fi x))
    (named-lambda? x) (lambda-expand-tree-unexported-lambda fi x)
	(lambda-expand-tree-0 fi x)))

(defun lambda-expand-tree-0 (fi x)
  (?
	(atom x)  x
	(atom x.) (listprop-cons x x. (lambda-expand-tree-0 fi .x))
    (progn
	  (listprop-cons x (lambda-expand-tree-cons fi x.)
		               (lambda-expand-tree-0 fi .x)))))

(defun lambda-expand-tree (fi x)
  (aprog1 (lambda-expand-tree-0 fi x)
    (place-expand-0 fi !)))

(defun transpiler-lambda-expand (tr x)
  (lambda-expand-tree (transpiler-global-funinfo tr) x))
