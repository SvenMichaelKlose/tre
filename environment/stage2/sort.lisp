(fn sort-divide (x left right test<)
  (with (i     left
         j     (-- right)
         pivot (elt x right))
    (while (< i j)
           nil
      (while (& (< i right)
                (not (~> test< pivot (elt x i))))
             nil
        (++! i))
      (while (& (> j left)
                (~> test< pivot (elt x j)))
             nil
        (--! j))
      (& (< i j)
         (xchg (elt x i) (elt x j))))
    (& (~> test< pivot (elt x i))
       (xchg (elt x i) (elt x right)))
    i))

(fn sort (x &key (test #'<))
  (with (f #'((left right)
                (when (< left right)
                  (let divisor (sort-divide x left right test)
                    (f left (-- divisor))
                    (f (++ divisor) right)))))
    (& x (f 0 (-- (length x)))))
  x)
