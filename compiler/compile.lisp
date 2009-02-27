;;;; TRE compiler
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Toplevel

(defvar *expanded-functions* nil)

(defun print-compiler-status (fun)
  (let body (function-body fun)
    (format t "(Processing ~A ~A)~%"
		      (if
			    (functionp fun)
				  "function"
				(macrop fun)
				  "macro")
              (if (eq 'block (first body.))
                  (symbol-name (second body.))
                  ""))))

(defun special-form-expand (x)
  (backquote-expand (compiler-macroexpand x)))

(defun atomic-lambda (fun)
  (with ((lambda-expansion fi)
	   	   (lambda-expand fun (special-form-expand (function-body fun))))
    fi))

(defun atomic-expand-lambda (fun)
  (with ((lambda-expansion fi)
   	       (lambda-expand fun (special-form-expand (function-body fun))))
	(funcall (compose (fn tree-expand fi _)
					  #'opt-peephole
					  (fn expression-expand (make-expex) _))
			 lambda-expansion)
    ;(setf (cdr (assoc fun *expanded-functions*)) fi)
    fi))

(defun compile (fun)
  (print-compiler-status fun)
  (if (compilable? fun)
      (and (atomic-expand-lambda fun)
		    nil)
      (error "function expected")))

(defun compile-all ()
  (dolist (i (reverse *universe*) nil)
    (awhen (symbol-function i)
      (when (compilable? !)
        (compile !)))))
