;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

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

;; XXX ECMAScript only.
(defun %setf-elt-string (val seq idx)
  (error "cannot modify strings"))

(dont-obfuscate to-string)

;; XXX ECMAScript only.
(defun string (x)
  (?
	(string? x)
	  x
	(character? x)
      (char-string x)
    (symbolp x)
	  (symbol-name x)
	(not x)
	  ,*nil-symbol-name*
   	(x.to-string)))

;(defun list-string (lst)
;  (when lst
;    (declare type cons lst)
;    (with (n (length lst)
;           s (make-string 0))
;      (do ((i 0 (integer-1+ i))
;           (l lst .l))
;          ((integer>= i n) s)
;        (setf s (+ s (string l.)))))))

;; XXX must be optional.
(defun string= (x y)
  (%%%= x y))

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
  (? (integer= start end)
	 ""
     (seq.substr start (- end start))))
