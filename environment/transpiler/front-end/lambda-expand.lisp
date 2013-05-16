;;;;; tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>


;;;; INLINING

(defun lambda-expand-make-inline-body (stack-places values body)
  `(%%block
	 ,@(mapcar #'((stack-place init-value)
				    `(%setq ,stack-place ,init-value))
			   stack-places values)
     ,@body))

(defun lambda-call-embed-0 (fi args vals body)
  (with ((a v) (assoc-splice (argument-expand 'dummy-in-lambda-call-embed args vals)))
    (funinfo-var-add-many fi a)
    (lambda-expand-tree fi (lambda-expand-make-inline-body a v body))))

(defun lambda-call-embed (fi lambda-call)
  (with-lambda-call (args vals body lambda-call)
    (lambda-call-embed-0 fi args vals body)))


;;;; EXPORT

(defvar *lexical-sym-counter* 0)

(defun lambda-export-make-lexical-sym ()
  (alet ($ '~L (1+! *lexical-sym-counter*))
    (? (& (eq ! (symbol-value !))
          (not (symbol-function !)))
       !
       (lambda-export-make-lexical-sym))))

(defun lambda-export-make-exported-name ()
  (alet (lambda-export-make-lexical-sym)
    (? (symbol-function !)
       (lambda-export-make-exported-name)
       !)))

(defun lambda-export (fi x)
  (with (name   (lambda-export-make-exported-name)
         args   (lambda-args x)
         body   (lambda-body x)
         new-fi (create-funinfo :name   name
                                :args   args
                                :parent fi))
    (funinfo-make-ghost new-fi)
    (acons! name args (transpiler-closure-argdefs *transpiler*))
    (transpiler-add-exported-closure *transpiler* `((defun ,name ,(funinfo-argdef new-fi) ,@body)))
    `(%%closure ,name)))


;;;; PASSTHROUGH

(defun lambda-expand-tree-unexported-lambda (fi x)
  (!? (get-funinfo (lambda-name x))
      (copy-lambda x :body (lambda-expand-tree-0 ! (lambda-body x)))
      (with (name   (| (lambda-name x)
                       (make-funinfo-sym))
             new-fi (create-funinfo :name   name
                                    :args   (lambda-args x)
                                    :parent fi))
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
	(atom x.) (cons x. (lambda-expand-tree-0 fi .x))
    (progn
      (make-default-listprop x)
	  (cons (lambda-expand-tree-cons fi x.)
		    (lambda-expand-tree-0 fi .x)))))

(defun lambda-expand-tree (fi x)
  (aprog1 (lambda-expand-tree-0 fi x)
    (with-temporary (transpiler-lambda-export? *transpiler*) t
      (place-expand-0 fi !))))

(defun transpiler-lambda-expand (tr x)
  (lambda-expand-tree (transpiler-global-funinfo tr) x))
