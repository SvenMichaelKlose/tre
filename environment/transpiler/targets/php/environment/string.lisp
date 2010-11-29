;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(dont-obfuscate is_string)

(defun stringp (x)
  (is_string x))

;; XXX must be optional.
(defun string-concat (&rest x)
  (apply #'+ x))

(dont-obfuscate ord strlen substr)

;; XXX ECMAScript only.
(defun %elt-string (seq idx)
  (when (%%%< idx (strlen seq))
    (ord (substr seq idx 1))))

(dont-obfuscate from-char-code)

;; XXX ECMAScript only.
(defun %setf-elt-string (val seq idx)
  (error "cannot modify strings"))

(dont-obfuscate strval)

;; XXX ECMAScript only.
(defun string (x)
  (if
	(stringp x)
	  x
	(characterp x)
      (char-string x)
    (symbolp x)
	  (symbol-name x)
	(not x)
	  ,*nil-symbol-name*
   	(strval x)))

;; XXX must be optional.
(defun string= (x y)
  (%%%= x y))

(dont-obfuscate strtoupper)

;; XXX ECMAScript only.
(defun string-upcase (x)
  (strtoupper x))

(dont-obfuscate strtolower)

;; XXX ECMAScript only.
(defun string-downcase (x)
  (strtolower x))

(dont-obfuscate substr)

;; XXX ECMAScript only.
(defun %subseq-string (seq start end)
  (if (= start end)
	  ""
      (substr seq start (- end start))))
