(fn make-hash-table (&key (test #'eql) (size nil))
  (%native "" "new __array ()"))

(fn hash-table? (x)
  (| (is_a x "__array")
     (%native "is_array ($" x ") && array_keys ($" x ") !== range (0, count ($" x ") - 1)")))

(fn %%key (x)
  (?
    (is_a x "__symbol")    (%string+ "~%S" x.n "~%P" (? (keyword? x)
                                                          "_kw"
                                                          x.p))
    (is_a x "__cons")      (%string+ "~%L" x.id)
    (is_a x "__array")     (%string+ "~%A" x.id)
    (is_a x "__character") (%string+ "~%C" x.v)
    x))

(fn %%unkey (x)
  (? (%== "~%" (substr x 0 2))
     (!= (substr x 3)
       (case (substr x 2 1) :test #'%==
         "S" (let boundary (strpos ! "~%P")
               (make-symbol (subseq ! 0 boundary)
                            (let-when p (subseq ! (+ 3 boundary))
                              (? (%== p "_kw")
                                 *keyword-package*
                                 (make-symbol p)))))
         "L" (%aref *conses* (substr x 3))
         "A" (%aref *arrays* (substr x 3))
         "C" (code-char (substr x 3))
         (error "Illegal index ~A." x)))
     x))

(fn hashkeys (x)
  (? (hash-table? x)
     (@ #'%%unkey (x.keys))
     (array-list (array_keys x))))

(fn href (h k)
  (!= (%%key k)
    (?
      (is_array h)
        (& (%aref-defined? h !)
           (%aref h !))
      (hash-table? h)
        (h.g !)
      (error "HASH-TABLE expected."))))

(fn (= href) (v h k)
  (!= (%%key k)
    (? (is_array h)
       (=-%aref v h !) v)
       (h.s (%%key !) v))
  v)
