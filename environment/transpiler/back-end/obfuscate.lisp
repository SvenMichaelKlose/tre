;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defvar *transpiler-obfuscation-counter* 0)

(defun transpiler-obfuscated-sym ()
  (1+! *transpiler-obfuscation-counter*)
  (number-sym *transpiler-obfuscation-counter*))

(defun transpiler-obfuscate-symbol-0 (tr x)
  (let obs (transpiler-obfuscations tr)
    (| (href obs x)
       (= (href obs x)
	      (!? (symbol-package x)
              (make-symbol (symbol-name (transpiler-obfuscated-sym)) (transpiler-obfuscate-symbol tr !))
              (transpiler-obfuscated-sym))))))

(defun obfuscateable-symbol? (tr x)
  (not (eq t (href (transpiler-obfuscations tr) (make-symbol (symbol-name x))))))

(defun must-obfuscate-symbol? (tr x)
  (& x
     (transpiler-obfuscate? tr)
     (obfuscateable-symbol? tr x)))

(defun transpiler-obfuscate-symbol (tr x)
  (? (must-obfuscate-symbol? tr x)
     (transpiler-obfuscate-symbol-0 tr x)
     x))

(define-tree-filter transpiler-obfuscate (tr x)
  (| (variablep x) (function? x))
	(transpiler-obfuscate-symbol tr x))

(defun transpiler-obfuscated-symbol-name (tr x)
  (symbol-name (transpiler-obfuscate-symbol tr x)))

(defun transpiler-obfuscated-symbol-string (tr x)
  (transpiler-symbol-string tr (transpiler-obfuscate-symbol tr x)))

(defun transpiler-print-obfuscations (tr)
  (dolist (k (hashkeys (transpiler-obfuscations tr)))
    (unless (in=? (elt (symbol-name k) 0) #\~) ; #\_)
	  (format t "~A~A -> ~A" (!? (symbol-package k)
                                 (string-concat (symbol-name !) ":")
                                 "")
                             (symbol-name k)
						     (href (transpiler-obfuscations tr) k)))))
