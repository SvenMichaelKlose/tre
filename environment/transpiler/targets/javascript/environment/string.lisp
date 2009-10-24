;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(js-type-predicate %stringp "string")

(defun stringp (x)
  (or (%stringp x)
	  (instanceof x (%transpiler-native "String"))))

;; XXX must be optional.
(defun string-concat (&rest x)
  (apply #'+ x))

(dont-obfuscate char-code-at)

;; XXX ECMAScript only.
(defun %elt-string (seq idx)
  (when (%%%< idx seq.length)
    (code-char (seq.char-code-at idx))))

(dont-obfuscate from-char-code)

;; XXX ECMAScript only.
(defun %setf-elt-string (val seq idx)
  (assert (characterp val)
    (error "can only write CHARACTER to string"))
  (setf (aref seq idx) (*string.from-char-code (char-code val))))

(dont-obfuscate to-string)

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
   	(x.to-string)))

(defun list-string (lst)
  (when lst
    (declare type cons lst)
    (let* ((n (length lst))
           (s (make-string 0)))
      (do ((i 0 (integer-1+ i))
           (l lst .l))
          ((integer>= i n) s)
        (setf s (+ s (string l.)))))))

;; XXX must be optional.
(defun string= (x y)
  (%%%= x y))

(dont-obfuscate to-upper-case)

;; XXX ECMAScript only.
(defun string-upcase (x)
  (x.to-upper-case))

(dont-obfuscate to-lower-case)

;; XXX ECMAScript only.
(defun string-downcase (x)
  (x.to-lower-case))

(dont-obfuscate substr length)

;; XXX ECMAScript only.
(defun %subseq-string (seq start end)
  (if (= start end)
	  ""
      (seq.substr start end)))
