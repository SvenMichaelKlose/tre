;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defvar *transpiler-obfuscation-counter* 0)

(defun transpiler-obfuscated-sym ()
  (incf *transpiler-obfuscation-counter*)
  (number-sym *transpiler-obfuscation-counter*))

(defun %transpiler-obfuscate-symbol-unpackaged (tr x)
  (let obs (transpiler-obfuscations tr)
    (or (href obs x)
        (setf (href obs x)
              (transpiler-obfuscated-sym)))))

(defun %transpiler-obfuscate-symbol-1 (tr x)
  (with (pack (symbol-package x)
	     n (%transpiler-obfuscate-symbol-unpackaged
		       tr
		       (if pack
		   	       (make-symbol (symbol-name x))
			       x)))
    (if pack
        (make-symbol (symbol-name n) pack)
	    n)))

(defun transpiler-obfuscate-symbol-0 (tr x)
  (if (or (not (transpiler-obfuscate? tr))
          (eq t (href (transpiler-obfuscations tr) (make-symbol (symbol-name x)))))
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
