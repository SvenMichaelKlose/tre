;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(dont-obfuscate is_string)

(defun string? (x)
  (is_string x))

(defun string-concat (&rest x)
  (let result ""
    (dolist (i x result)
      (setf result (%%%string+ result i)))))

(dont-obfuscate ord strlen substr)

(defun %elt-string (seq idx)
  (when (%%%< idx (strlen seq))
    (code-char (ord (substr seq idx 1)))))

(dont-obfuscate from-char-code)

(defun %setf-elt-string (val seq idx)
  (error "cannot modify strings"))

(dont-obfuscate strval)

(defun string (x)
  (?
	(string? x)
	  x
	(characterp x)
      (char-string x)
    (symbol? x)
	  (symbol-name x)
	(not x)
	  ,*nil-symbol-name*
   	(strval x)))

(defun string= (x y)
  (%%%= x y))

(dont-obfuscate strtoupper)

(defun string-upcase (x)
  (strtoupper x))

(dont-obfuscate strtolower)

(defun string-downcase (x)
  (strtolower x))

(dont-obfuscate substr)

(defun %subseq-string (seq start end)
  (? (= start end)
	 ""
     (substr seq start (- end start))))
