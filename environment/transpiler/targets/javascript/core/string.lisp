; tré – Copyright (c) 2008–2016 Sven Michael Klose <pixel@copei.de>

(declare-cps-exception string %string? string? string== string-concat upcase downcase string-subseq)
(dont-obfuscate push join char-code-at to-string to-upper-case to-lower-case substr length)

(js-type-predicate %string? "string")

(defun string? (x)
  (| (%string? x)
     (instanceof x (%%native "String"))))

(defun string-concat (&rest x)
  (alet (make-array)
    (@ (i x (!.join ""))
      (& i (!.push i)))))

(defun %elt-string (seq idx)
  (& (%%%< idx seq.length)
     (code-char (seq.char-code-at idx))))

(defun string== (x y)
  (%%%== x y))

(defmacro string== (x y)
  `(%%%== ,x ,y))

(defun upcase (x)
  (& x (x.to-upper-case)))

(defun downcase (x)
  (& x (x.to-lower-case)))

(defun string-subseq (seq start &optional (end 99999))
  (unless (< (%%%- (length seq) 1) start end)
    (? (integer== start end)
	   ""
       (seq.substr start (- end start)))))

(defun number-string (x)
  (*String x))
