;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Obfuscation

(defun transpiler-obfuscate-symbol (tr x)
  (unless (or (find x (transpiler-obfuscation-exceptions tr))
			  (assoc x (transpiler-obfuscations tr)))
    (setf (transpiler-obfuscations tr) (acons x (gensym) (transpiler-obfuscations tr)))))

(defun transpiler-obfuscate-keyword (tr x)
  (with (s (make-symbol (symbol-name x)))
    (unless (find s (transpiler-obfuscation-exceptions tr))
      (aif (assoc s (transpiler-obfuscations tr))
           (setf (transpiler-obfuscations tr) (acons x (cdr !) (transpiler-obfuscations tr)))
		   (progn
		     (transpiler-obfuscate-symbol tr s)
		     (transpiler-obfuscate-keyword tr x))))))

(defun transpiler-obfuscate (tr x)
  (if (transpiler-obfuscate? tr)
      (maptree #'((x)
			        (if (atom x)
					    (aif (assoc x (transpiler-obfuscations tr))
						     (cdr !)
					    	 x)
						x))
		       x)
	  x))
