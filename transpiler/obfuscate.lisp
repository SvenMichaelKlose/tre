;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Obfuscation

(defun transpiler-obfuscate (tr x)
  (if (transpiler-obfuscate? tr)
      (maptree #'((x)
			        (if (and (variablep x)
						     (not (keywordp x))
						     (assoc x (transpiler-function-args tr)))
					    (aif (assoc x (transpiler-obfuscations tr))
						     (cdr !)
						     (with (g (gensym))
						       (acons! x g (transpiler-obfuscations tr))
						       g))
					    x))
		       x)
	  x))
