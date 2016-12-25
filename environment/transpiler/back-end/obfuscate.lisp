(defvar *obfuscation-counter* 0)

(defun obfuscate? ()
  (enabled-pass? :obfuscate))

(defun obfuscateable-symbol? (x)
  (not (eq t (href (obfuscations) (make-symbol (symbol-name x))))))

(defun must-obfuscate-symbol? (x)
  (& x 
     (obfuscate?)
     (obfuscateable-symbol? x)))

(defun firefox-symbol-table-bug-workaround (x)
  (+ x (list #\_)))

(defun gen-obfuscated-symbol ()
  (++! *obfuscation-counter*)
  (with (to-alpha  [unless (zero? _)
	                (alet (mod _ 24)
	                  (. (+ #\a !)
                         (to-alpha (/ (- _ !) 24))))])
    (make-symbol (list-string (firefox-symbol-table-bug-workaround (to-alpha *obfuscation-counter*))))))

(defun obfuscated-symbol (x)
  (? (cl:packagep x) ; TODO: Introduce package objects.
     (= x (make-symbol (package-name x))))
  (? (must-obfuscate-symbol? x)
     (cache (!? (symbol-package x)
                (make-symbol (symbol-name (gen-obfuscated-symbol))
                             (package-name !))
                (gen-obfuscated-symbol))
            (href (obfuscations) x))
     x))

(define-tree-filter obfuscate-0 (x)
  (symbol? x)  (obfuscated-symbol x))

(defun obfuscate (x)
  (? (obfuscate?)
     (obfuscate-0 x)
     x))

(defun obfuscated-symbol-name (x)
  (symbol-name (obfuscated-symbol x)))

(defun obfuscated-identifier (x)
  (convert-identifier (obfuscated-symbol x)))

(defun transpiler-print-obfuscations (tr)
  (@ (k (hashkeys (transpiler-obfuscations tr)))
    (unless (find (elt (symbol-name k) 0) '(#\~)) ; #\_)
      (format t "~A~A -> ~A~%"
              (!? (symbol-package k)
                  (+ (package-name !) ":")
                  "")
              (symbol-name k)
              (href (transpiler-obfuscations tr) k)))))
