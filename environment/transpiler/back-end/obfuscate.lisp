;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defvar *transpiler-obfuscation-counter* 0)

(defun transpiler-obfuscated-sym ()
  (incf *transpiler-obfuscation-counter*)
  (number-sym *transpiler-obfuscation-counter*))

(defun transpiler-obfuscate-symbol-0 (tr x)
  (let obs (transpiler-obfuscations tr)
    (or (href obs x)
        (setf (href obs x)
			  (aif (symbol-package x)
    		       (make-symbol (symbol-name (transpiler-obfuscated-sym))
						        !)
    		       (transpiler-obfuscated-sym))))))

(defun must-obfuscate-symbol? (tr x)
  (and x
	   (transpiler-obfuscate? tr)
	   (not (eq t (href (transpiler-obfuscations tr)
						(make-symbol (symbol-name x)))))))

(defun transpiler-obfuscate-symbol (tr x)
  (if (must-obfuscate-symbol? tr x)
	  (transpiler-obfuscate-symbol-0 tr x)
	  x))

(defun transpiler-obfuscate (tr x)
  (if
	(consp x)
	  (cons (transpiler-obfuscate tr x.)
		    (transpiler-obfuscate tr .x))
    (and (or (variablep x)
	         (functionp x)))
	  (transpiler-obfuscate-symbol tr x)
	x))

(defun transpiler-obfuscated-symbol-string (tr x)
  (transpiler-symbol-string tr
	  (transpiler-obfuscate-symbol tr x)))

(defun transpiler-print-obfuscations (tr)
  (dolist (k (hashkeys (transpiler-obfuscations tr)))
    (unless (in=? (elt (symbol-name k) 0) #\~) ; #\_)
	  (format t "~A -> ~A" (symbol-name k)
						   (href (transpiler-obfuscations tr) k)))))
