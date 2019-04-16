(js-type-predicate %string? "string")

(fn string? (x)
  (%string? x))

(fn string-concat (&rest x)
  (!= (make-array)
    (@ (i x (!.join ""))
      (& i (!.push i)))))

(fn %elt-string (seq idx)
  (& (%%%< idx seq.length)
     (code-char (seq.char-code-at idx))))

(fn string== (x &rest y)
  (@ (i y t)
    (| (%%%== x i)
       (return))))

(functional upcase)
(fn upcase (x)
  (x.to-upper-case))

(functional downcase)
(fn downcase (x)
  (x.to-lower-case))

(functional string-subseq)
(fn string-subseq (seq start &optional (end 99999))
  (unless (& (< (- (length seq) 1) start)
             (< start end))
    (unless (== start end)
      (seq.substr start (- end start)))))

(functional number-string)
(fn number-string (x)
  (*String x))
