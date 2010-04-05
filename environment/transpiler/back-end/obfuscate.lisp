;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defvar *transpiler-obfuscation-counter* 0)

(defun transpiler-obfuscated-sym ()
  (incf *transpiler-obfuscation-counter*)
  (number-sym *transpiler-obfuscation-counter*))

(defun %transpiler-obfuscate-symbol-1 (tr x)
  (let obs (transpiler-obfuscations tr)
    (or (href obs x)
        (setf (href obs x)
			  (aif (symbol-package x)
    		       (make-symbol (symbol-name (transpiler-obfuscated-sym))
						        !)
    		       (transpiler-obfuscated-sym))))))

(defun transpiler-obfuscate-symbol-0 (tr x)
  (if (or (not (transpiler-obfuscate? tr))
          (eq t (href (transpiler-obfuscations tr) x)))
      x
	  (%transpiler-obfuscate-symbol-1 tr x)))

(defun transpiler-obfuscate-symbol (tr x)
  (when x
	(transpiler-obfuscate-symbol-0 tr x)))

(defun transpiler-obfuscate (tr x)
  (if (transpiler-obfuscate? tr)
      (if (atom x)
          (if (or (variablep x)
		          (functionp x))
	 	      (transpiler-obfuscate-symbol tr x)
	          x)
	      (cons (transpiler-obfuscate tr x.)
			    (transpiler-obfuscate tr .x)))
	  x))

(defun transpiler-obfuscated-symbol-string (tr x)
  (transpiler-symbol-string tr
	  (transpiler-obfuscate-symbol tr x)))

(defun transpiler-print-obfuscations (tr)
  (dolist (k (hashkeys (transpiler-obfuscations tr)))
    (unless (in=? (elt (symbol-name k) 0) #\~) ; #\_)
	  (format t "~A -> ~A" (symbol-name k)
						   (href (transpiler-obfuscations tr) k)))))
