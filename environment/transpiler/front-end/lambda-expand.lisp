;;;;; tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

;;;; INLINING

(defun lambda-expand-make-inline-body (stack-places values body)
  `(%%block
	 ,@(mapcar #'((stack-place init-value)
				    `(%setq ,stack-place ,init-value))
			   stack-places values)
     ,@body))

(defun lambda-call-embed (lambda-call)
  (with-lambda-call (args vals body lambda-call)
    (with ((a v) (assoc-splice (argument-expand 'dummy-in-lambda-call-embed args vals)))
      (funinfo-var-add-many *funinfo* a)
      (lambda-expand-tree (lambda-expand-make-inline-body a v body)))))


;;;; EXPORT

(define-gensym-generator closure-name ~closure-)

(defun lambda-export (x)
  (with (name    (closure-name)
         args    (lambda-args x)
         body    (lambda-body x)
         new-fi  (create-funinfo :name   name
                                 :args   args
                                 :body   body
                                 :parent *funinfo*
                                 :cps?   (transpiler-cps-transformation? *transpiler*)))
    (funinfo-make-ghost new-fi)
    (transpiler-add-exported-closure *transpiler* `((defun ,name ,(funinfo-argdef new-fi) ,@body)))
    `(%%closure ,name)))


;;;; PASSTHROUGH

(defun lambda-expand-tree-unexported-lambda (x)
  (!? (get-funinfo (lambda-name x))
      (with-temporary *funinfo* !
        (copy-lambda x :body (lambda-expand-tree (lambda-body x))))
      (with (name    (| (lambda-name x)
                        (funinfo-sym))
             new-fi  (create-funinfo :name   name
                                     :args   (lambda-args x)
                                     :body   (lambda-body x)
                                     :parent *funinfo*
                                     :cps?   (transpiler-cps-transformation? *transpiler*)))
        (funinfo-var-add *funinfo* name)
        (with-temporary *funinfo* new-fi
          (copy-lambda x :name name :body (lambda-expand-tree (lambda-body x)))))))


;;;; TOPLEVEL

(defun lambda-expand-tree-cons (x)
  (& (%set-atom-fun? x)
     (lambda? ..x.)
     (funinfo-add-local-function-args *funinfo* .x. (lambda-args ..x.)))
  (?
    (lambda-call? x)   (lambda-call-embed x)
    (lambda? x)        (? (transpiler-lambda-export? *transpiler*)
                          (lambda-export x)
                          (lambda-expand-tree-unexported-lambda x))
    (named-lambda? x)  (lambda-expand-tree-unexported-lambda x)
	(lambda-expand-tree x)))

(defun lambda-expand-tree (x)
  (?
    (atom x)   x
    (atom x.)  (listprop-cons x x. (lambda-expand-tree .x))
    (listprop-cons x (lambda-expand-tree-cons x.)
	                 (lambda-expand-tree .x))))


(defun transpiler-lambda-expand (tr x)
  (with-global-funinfo
    (lambda-expand-tree x)))
