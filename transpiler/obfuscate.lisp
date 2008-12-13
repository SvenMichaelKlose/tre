;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Obfuscation

(defvar *transpiler-obfuscation-counter* 0)

(defun transpiler-obfuscated-sym ()
  (with (digit
		  (fn (if (< _ 24)
				  (+ #\a _)
				  (+ (- #\0 24) _)))
		 rec
		   (fn (unless (= 0 _)
				 (with (m (mod _ 34))
				   (cons (digit m)
						 (rec (/ (- _ m) 34)))))))
	(incf *transpiler-obfuscation-counter*)
	(make-symbol (list-string (cons #\_ (rec *transpiler-obfuscation-counter*))))))

(defun transpiler-obfuscate-symbol (tr x)
  (when (transpiler-obfuscate? tr)
    (unless (or (find x (transpiler-obfuscation-exceptions tr))
			    (href x (transpiler-obfuscations tr)))
      (setf (href x (transpiler-obfuscations tr)) (transpiler-obfuscated-sym)))))

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
