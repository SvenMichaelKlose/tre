;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defvar *transpiler-obfuscation-counter* 0)

(defun transpiler-obfuscated-sym ()
	(incf *transpiler-obfuscation-counter*)
	(number-sym *transpiler-obfuscation-counter*))

(defun transpiler-obfuscate-symbol (tr x)
  (if (or (not (transpiler-obfuscate? tr))
          (member x (transpiler-obfuscation-exceptions tr)))
	  x
      (aif (href x (transpiler-obfuscations tr))
		   !
           (setf (href x (transpiler-obfuscations tr))
		         (transpiler-obfuscated-sym)))))

(defun transpiler-obfuscate (tr x)
  (if (transpiler-obfuscate? tr)
      (maptree (fn (when (expex-sym? _)
					 (transpiler-obfuscate-symbol tr _))
			       (if (or (variablep _)
						   (functionp _))
					   (aif (href _ (transpiler-obfuscations tr))
						    !
					    	_)
					   _))
		       x)
	  x))
