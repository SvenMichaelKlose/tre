;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(js-type-predicate %string? "string")

(defun string? (x)
  (| (%string? x)
     (instanceof x (%transpiler-native "String"))))

(dont-obfuscate push join)

(defun string-concat (&rest x)
  (let-when a (remove-if #'not x)
    (let res (make-array)
      (dolist (i a (res.join ""))
        (res.push i)))))

(dont-obfuscate char-code-at)

(defun %elt-string (seq idx)
  (& (%%%< idx seq.length)
     (code-char (seq.char-code-at idx))))

(dont-obfuscate from-char-code)

,(& *transpiler-assert*
    '(defun %=-elt-string (val seq idx)
       (error "cannot modify strings")))

(dont-obfuscate to-string)

(defun string (x)
  (?
	(string? x) x
	(character? x) (char-string x)
    (symbol? x) (symbol-name x)
	(not x) ,*nil-symbol-name*
   	(x.to-string)))

(defun string== (x y)
  (%%%== x y))

(dont-obfuscate to-upper-case)

(defun string-upcase (x)
  (& x (x.to-upper-case)))

(dont-obfuscate to-lower-case)

(defun string-downcase (x)
  (& x (x.to-lower-case)))

(dont-obfuscate substr length)

(defun string-subseq (seq start &optional (end 99999))
  (unless (< (%%%- (length seq) 1) start end)
    (?
      (integer== start end)
	    ""
      (seq.substr start (- end start)))))
