;;;;; tré – Copyright (c) 2005–2012 Sven Michael Klose <pixel@copei.de>

(defun lambda-make-funinfo (args parent)
  (with (argnames (argument-expand-names 'lambda-expand args)
         fi (make-funinfo :args argnames :parent parent))
    (funinfo-env-add fi '~%ret)
    ; XXX nicer when moved to place-assign/expand
    (& (transpiler-copy-arguments-to-stack? *current-transpiler*)
       (funinfo-env-add-many fi argnames))
	fi))

;;;; Inlining

(defun lambda-expand-make-inline-body (stack-places values body)
  `(%%vm-scope
	 ,@(mapcar #'((stack-place init-value)
				    `(%setq ,stack-place ,init-value))
			   stack-places values)
     ,@body))

(defun lambda-call-embed (fi lambda-call)
  (with-lambda-call (args vals body lambda-call)
    (with ((a v) (assoc-splice (argument-expand 'dummy-in-lambda-call-embed args vals)))
	  (funinfo-env-add-many fi a)
	  (lambda-expand-tree fi (lambda-expand-make-inline-body a v body)))))

;;;; Export

(defvar *lexical-sym-counter* 0)

(defun lambda-export-make-exported (fi x)
  (let exported-name ($ '~L (1+! *lexical-sym-counter*))
    (let fi-exported (lambda-make-funinfo (lambda-args x) fi)
	  (funinfo-make-ghost fi-exported)
	  (lambda-expand-tree fi-exported (lambda-body x))
      (let argdef (append (awhen (funinfo-ghost fi-exported)
						    (list !))
						  (lambda-args x))
		(acons! exported-name argdef *closure-argdefs*)
	    (transpiler-add-exported-closure *current-transpiler*
            `((defun ,exported-name ,(append (make-lambda-funinfo fi-exported) argdef)
		        ,@(lambda-body x)))))
	  (values exported-name fi-exported))))

(defun lambda-export (fi x)
  (with ((exported-name fi-exported) (lambda-export-make-exported fi x))
    `(%%funref ,exported-name
               ,(funinfo-sym fi-exported))))

;;;; Passthrough

(defun lambda-expand-tree-unexported-lambda (fi x)
  (with (new-fi (| (& (lambda-funinfo x) (get-lambda-funinfo x))
				   (lambda-make-funinfo (lambda-args x) fi))
		 body (lambda-expand-tree-0 new-fi (lambda-body x)))
	(copy-lambda x :info new-fi :body body)))

;;;; Toplevel

(defun lambda-expand-tree-cons (fi x)
  (& (%set-atom-fun? x)
     (lambda? ..x.)
     (funinfo-add-local-function-args fi .x. (lambda-args ..x.)))
  (?
    (lambda-call? x) (lambda-call-embed fi x)
    (lambda? x) (? (& (transpiler-lambda-export? *current-transpiler*)
                      (not (eq fi (transpiler-global-funinfo *current-transpiler*) )))
                   (lambda-export fi x)
		           (lambda-expand-tree-unexported-lambda fi x))
	(lambda-expand-tree-0 fi x)))

(defun lambda-expand-tree-0 (fi x)
  (?
	(atom x) x
	(atom x.) (cons x. (lambda-expand-tree-0 fi .x))
	(cons (lambda-expand-tree-cons fi x.)
		  (lambda-expand-tree-0 fi .x))))

(defun lambda-expand-tree (fi x)
  (aprog1 (lambda-expand-tree-0 fi x)
    (with-temporary (transpiler-lambda-export? *current-transpiler*) t
      (place-expand-0 fi !))))

(defun transpiler-lambda-expand (tr x)
  (lambda-expand-tree (transpiler-global-funinfo tr) x))
