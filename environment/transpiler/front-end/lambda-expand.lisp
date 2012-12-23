;;;;; tré – Copyright (c) 2005–2012 Sven Michael Klose <pixel@copei.de>

(defun lambda-make-funinfo (args parent)
  (with (argnames (argument-expand-names 'lambda-expand args)
         fi (make-funinfo :argdef args
                          :args argnames
                          :parent parent
                          :transpiler *current-transpiler*))
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

(defun lambda-call-embed-0 (fi args vals body)
  (with ((a v) (assoc-splice (argument-expand 'dummy-in-lambda-call-embed args vals)))
    (funinfo-env-add-many fi a)
     (lambda-expand-tree fi (lambda-expand-make-inline-body a v body))))

(defun lambda-call-embed (fi lambda-call)
  (with-lambda-call (args vals body lambda-call)
    (lambda-call-embed-0 fi args vals body)))

(defvar *embedded-lambda-funrefs* nil)

(defun lambda-funref-embed (fi x)
  (with (fun (cadr x.)
         tr  *current-transpiler*)
    (with-temporary *embedded-lambda-funrefs* (cons fun *embedded-lambda-funrefs*)
      (lambda-call-embed-0 fi (| (transpiler-function-arguments tr fun)
                                 (function-arguments (symbol-function fun)))
                              (rename-body-tags (transpiler-frontend-1 tr (| (transpiler-function-body tr fun)
                                                                             (function-body (symbol-function fun)))))
                              .x))))

;;;; Export

(defvar *lexical-sym-counter* 0)

(defun lambda-export-make-lexical-sym ()
  (alet ($ '~L (1+! *lexical-sym-counter*))
    (? (& (eq ! (symbol-value !))
          (not (symbol-function !)))
       !
       (lambda-export-make-lexical-sym))))

(defun lambda-export-make-exported-name ()
  (let exported-name (lambda-export-make-lexical-sym)
    (? (symbol-function exported-name)
       (lambda-export-make-exported-name)
       exported-name)))

(defun lambda-export (fi x)
  (with (exported-name (lambda-export-make-exported-name)
         fi-exported (lambda-make-funinfo (lambda-args x) fi))
    (funinfo-make-ghost fi-exported)
    (lambda-expand-tree fi-exported (lambda-body x))
    (let argdef (funinfo-args fi-exported)
      (acons! exported-name argdef *closure-argdefs*)
      (transpiler-add-exported-closure *current-transpiler*
          `((defun ,exported-name ,(+ (make-lambda-funinfo fi-exported) argdef)
              ,@(lambda-body x)))))
    `(%%funref ,exported-name ,(funinfo-sym fi-exported))))

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
;    (& (cons? x)
;       (cons? x.)
;       (eq 'function x..)
;       (atom (cadr x.))
;       (not (builtin? (symbol-function (cadr x.))))
;       (not (cddr x.))
;       (not (member (cadr x.) *embedded-lambda-funrefs* :test #'eq)))
;                          (lambda-funref-embed fi x)
    (lambda-call? x)      (lambda-call-embed fi x)
    (lambda? x)           (? (& (transpiler-lambda-export? *current-transpiler*)
                                (not (eq fi (transpiler-global-funinfo *current-transpiler*) )))
                             (lambda-export fi x)
		                     (lambda-expand-tree-unexported-lambda fi x))
	(lambda-expand-tree-0 fi x)))

(defun lambda-expand-tree-0 (fi x)
  (?
	(atom x) x
	(atom x.) (cons x. (lambda-expand-tree-0 fi .x))
    (progn
      (awhen (cpr x)
        (= *default-listprop* !))
	  (cons (lambda-expand-tree-cons fi x.)
		    (lambda-expand-tree-0 fi .x)))))

(defun lambda-expand-tree (fi x)
  (aprog1 (lambda-expand-tree-0 fi x)
    (with-temporary (transpiler-lambda-export? *current-transpiler*) t
      (place-expand-0 fi !))))

(defun transpiler-lambda-expand (tr x)
  (lambda-expand-tree (transpiler-global-funinfo tr) x))
