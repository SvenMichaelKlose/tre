(functional upcase downcase string-subseq number-string)

(js-type-predicate %string? "string")

(fn string? (x)
  (| (%string? x)
     (instanceof x (%native "String"))))

(fn string-concat (&rest x)
  (!= #()
    (@ (i x (!.join ""))
      (& i (!.push i)))))

(fn string== (x &rest y)
  (@ (i y t)
    (| (%%%== x i)
       (return))))

(fn upcase (x)
  (x.to-upper-case))

(fn downcase (x)
  (x.to-lower-case))

(fn string-subseq (seq start &optional (end nil))
  (unless (& (< (- (length seq) 1) start)
             (? end
                (< start end)
                t))
    (unless (== start end)
      (seq.substr start (? end (- end start))))))

(fn number-string (x)
  (*String x))
