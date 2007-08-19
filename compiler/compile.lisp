;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (C) 2005, 2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Compiler toplevel

(defvar *expanded-functions* nil)

(defun atom-expand-lambda (fun mex &optional (parent-env nil))
  (with ((lex fi) (lambda-expand! fun mex parent-env)
         eex (expex-expand-body lex))
    (tree-expand fi eex)
    (setf (assoc fun *expanded-functions*) fi)
    (values eex fi)))
 
(defun atomic-expand-fun (fun)
  (with (body (function-body fun))
    (format t "(compile ~A)~%"
              (if (eq (first (car body)) 'block)
                  (symbol-name (second (car body)))
                  ""))
    (atom-expand-lambda fun (compiler-macroexpand body))))
 
; Replace function by optimized version.
(defun atomic-expand (fun)
  (when (second (symbol-value fun))
    (if (functionp fun)
        (atomic-expand-fun fun)
        (error "function expected"))))

(defun compile (fun)
  (atomic-expand fun))

(defun atomic-expand-all ()
  (dolist (i (reverse *universe*))
    (awhen (symbol-function i)
      (when (functionp !)
        (atomic-expand !))
      (do-tests *tests*))))

(defun compile-all ()
  (tree-expand-reset)
  (atomic-expand-all))

(defun test ()
  '(a b))

;(compile #'test)
