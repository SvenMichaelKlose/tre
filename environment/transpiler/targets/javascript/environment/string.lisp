;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(js-type-predicate %string? "string")

(defun string? (x)
  (or (%string? x)
	  (instanceof x (%transpiler-native "String"))))

;; XXX must be optional.
(defun string-concat (&rest x)
  (apply #'+ (mapcar (fn or _ "") x)))

(dont-obfuscate char-code-at)

;; XXX ECMAScript only.
(defun %elt-string (seq idx)
  (when (%%%< idx seq.length)
    (code-char (seq.char-code-at idx))))

(dont-obfuscate from-char-code)

,(when *transpiler-assert*
   '(defun %setf-elt-string (val seq idx)
      (error "cannot modify strings")))

(dont-obfuscate to-string)

;; XXX ECMAScript only.
(defun string (x)
  (?
	(string? x) x
	(character? x) (char-string x)
    (symbol? x) (symbol-name x)
	(not x) ,*nil-symbol-name*
   	(x.to-string)))

;; XXX must be optional.
(defun string== (x y)
  (%%%== x y))

(dont-obfuscate to-upper-case)

;; XXX ECMAScript only.
(defun string-upcase (x)
  (when x
    (x.to-upper-case)))

(dont-obfuscate to-lower-case)

;; XXX ECMAScript only.
(defun string-downcase (x)
  (when x
    (x.to-lower-case)))

(dont-obfuscate substr length)

;; XXX ECMAScript only.
(defun %subseq-string (seq start end)
  (unless (< (%%%- (length seq) 1) start end)
    (?
      (integer== start end)
	    ""
      (seq.substr start (- end start)))))
