;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *obfuscation-counter* 0)

(defun number-sym-0 (x)
  (unless (== 0 x)
	(let m (mod x 24)
	  (cons (+ #\a m)
			(number-sym-0 (/ (- x m) 24))))))

(defun number-sym (x)
  (make-symbol (list-string (nconc (number-sym-0 x) (list #\_)))))

(defun obfuscated-sym ()
  (++! *obfuscation-counter*)
  (number-sym *obfuscation-counter*))

(defun obfuscate-symbol-0 (x)
  (let obs (transpiler-obfuscations *transpiler*)
    (| (href obs x)
       (= (href obs x)
	      (!? (symbol-package x)
              (make-symbol (symbol-name (obfuscated-sym)) (obfuscate-symbol !))
              (obfuscated-sym))))))

(defun obfuscateable-symbol? (x)
  (not (eq t (href (transpiler-obfuscations *transpiler*) (make-symbol (symbol-name x))))))

(defun must-obfuscate-symbol? (x)
  (& x
     (transpiler-obfuscate? *transpiler*)
     (obfuscateable-symbol? x)))

(defun obfuscate-symbol (x)
  (? (must-obfuscate-symbol? x)
     (obfuscate-symbol-0 x)
     x))

(define-tree-filter obfuscate (x)
  (symbol? x) (obfuscate-symbol x))

(defun obfuscated-symbol-name (x)
  (symbol-name (obfuscate-symbol x)))

(defun obfuscated-symbol-string (x)
  (transpiler-symbol-string (obfuscate-symbol x)))

(defun transpiler-print-obfuscations (tr)
  (dolist (k (hashkeys (transpiler-obfuscations tr)))
    (unless (in=? (elt (symbol-name k) 0) #\~) ; #\_)
	  (format t "~A~A -> ~A~%" (!? (symbol-package k)
                                   (string-concat (symbol-name !) ":")
                                   "")
                               (symbol-name k)
						       (href (transpiler-obfuscations tr) k)))))
