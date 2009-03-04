;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defvar *transpiler-obfuscation-counter* 0)

(defun transpiler-obfuscated-sym ()
	(incf *transpiler-obfuscation-counter*)
	(number-sym *transpiler-obfuscation-counter*))

(defun transpiler-obfuscate-symbol (tr x)
  (when x
    (if (or (not (transpiler-obfuscate? tr))
            (member x (transpiler-obfuscation-exceptions tr)))
	    x
        (aif (href x (transpiler-obfuscations tr))
		     !
             (setf (href x (transpiler-obfuscations tr))
		           (make-symbol (symbol-name (transpiler-obfuscated-sym))
								(symbol-package x)))))))

(defun transpiler-obfuscate (tr x)
  (if (atom x)
      (if (or (variablep x)
		      (functionp x))
	 	  (transpiler-obfuscate-symbol tr x)
	      x)
	  (cons (transpiler-obfuscate tr x.)
			(transpiler-obfuscate tr .x))))
