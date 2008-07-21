;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Compiler toplevel

(defvar *expanded-functions* nil)

(defun atomic-expand-lambda (fun mex &optional (parent-env nil))
  (with ((lex fi) (lambda-expand fun (backquote-expand mex) parent-env))
    (tree-expand fi (opt-peephole (expression-expand (make-expex) lex)))
fi
))
    ;(setf (cdr (assoc fun *expanded-functions*)) fi)
 
(defun atomic-expand-fun (fun)
  (with (body (function-body fun))
    (format t "(Processing ~A ~A)~%"
			  (cond
				((functionp fun)	"function")
				((macrop fun)	"macro"))
              (if (eq (first (car body)) 'block)
                  (symbol-name (second (car body)))
                  ""))
    (atomic-expand-lambda fun (compiler-macroexpand body))))

(defun compilable? (x)
  (or (functionp x) (macrop x)))
 
; Replace function by optimized version.
(defun atomic-expand (fun)
  (when (second (symbol-value fun))
    (if (compilable? fun)
        (atomic-expand-fun fun)
        (error "function expected"))))

(defun compile (fun)
  (atomic-expand fun))

(defun atomic-expand-all ()
  (dolist (i (reverse *universe*))
    (awhen (symbol-function i)
      (when (compilable? !)
        (atomic-expand !))
      ;(do-tests *tests*)
)))

(defun compile-all ()
  (atomic-expand-all)
  nil)
