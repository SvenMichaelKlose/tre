;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Obfuscation

(defvar *transpiler-obfuscation-counter* 0)

(defun transpiler-obfuscated-sym ()
  (with (digit #'((n)
				    (if (< n 24)
					    (+ #\a n)
						(+ (- #\0 24) n)))
		 rec #'((x)
				  (unless (= 0 x)
					(with (m (mod x 34))
					  (cons (digit m)
							(rec (/ (- x m) 34)))))))
	(incf *transpiler-obfuscation-counter*)
	(make-symbol (list-string (cons #\_ (rec *transpiler-obfuscation-counter*))))))

(defun transpiler-obfuscate-symbol (tr x)
  (when (transpiler-obfuscate? tr)
    (unless (or (find x (transpiler-obfuscation-exceptions tr))
			    (gethash x (transpiler-obfuscations tr)))
      (setf (gethash x (transpiler-obfuscations tr)) (transpiler-obfuscated-sym)))))

(defun transpiler-obfuscate (tr x)
  (if (transpiler-obfuscate? tr)
      (maptree #'((x)
					(when (expex-sym? x)
					  (transpiler-obfuscate-symbol tr x))
			        (if (or (variablep x)
						    (functionp x))
					    (aif (gethash x (transpiler-obfuscations tr))
						     !
					    	 x)
						x))
		       x)
	  x))
