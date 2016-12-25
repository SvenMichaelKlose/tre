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

(defun string== (x &rest y)
  (@ (i y t)
    (| (%%%== x i)
       (return))))

(defmacro string== (x &rest y)
  `(%%%== ,x ,@y))

(defun upcase (x)
  (& x (x.to-upper-case)))  ; TODO: No need to check if not NIL.

(defun downcase (x)
  (& x (x.to-lower-case)))

(defun string-subseq (seq start &optional (end 99999))
  (unless (& (< (- (length seq) 1) start)
             (< start end))
    (? (integer== start end)
	   ""
       (seq.substr start (- end start)))))

(defun number-string (x)
  (*String x))
