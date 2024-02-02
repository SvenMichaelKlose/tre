(fn string? (x)    (is_string x))
(fn string== (x y) (%%%== x y))
(fn upcase (x)     (strtoupper x))
(fn downcase (x)   (strtolower x))

(fn string-concat (&rest x)
  (!? (remove-if #'not x)
      (implode (list-phparray !))))

(fn string-subseq (seq start &optional (end nil))
  (unless (== start end)
    (!= (substr seq start (? end (- end start)))
      (unless (& (string? !) (== 0 (length !)))
        !))))

(fn number-string (x)
    (%native "(string)$" x))
