(js-type-predicate %string? "string")

(fn string? (x)
  (%string? x))

(fn string-concat (&rest x)
  (alet (make-array)
    (@ (i x (!.join ""))
      (& i (!.push i)))))

(fn %elt-string (seq idx)
  (& (%%%< idx seq.length)
     (code-char (seq.char-code-at idx))))

(fn string== (x &rest y)
  (@ (i y t)
    (| (%%%== x i)
       (return))))

(defmacro string== (x &rest y)
  `(%%%== ,x ,@y))

(fn upcase (x)
  (x.to-upper-case))

(fn downcase (x)
  (x.to-lower-case))

(fn string-subseq (seq start &optional (end 99999))
  (unless (& (< (- (length seq) 1) start)
             (< start end))
    (unless (== start end)
      (seq.substr start (- end start)))))

(fn number-string (x)
  (*String x))
