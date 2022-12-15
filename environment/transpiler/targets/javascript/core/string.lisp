(js-type-predicate %string? "string")

(fn string? (x)
  (| (%string? x)
     (instanceof x (%%native "String"))))

(fn string-concat (&rest x)
  (!= #()
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
(fn string-subseq (seq start &optional (end nil))
  (unless (& (< (- (length seq) 1) start)
             (? end
                (< start end)
                t))
    (unless (== start end)
      (seq.substr start (? end (- end start))))))

(functional number-string)
(fn number-string (x)
  (*String x))
