(fn make-array (&rest dimensions)
  (aprog1 (%%native "" "new __array ()")
    (dotimes (i dimensions.)
      (= (aref ! i) (!? .dimensions
                        (apply #'make-array !))))))

(fn array? (x)
  (| (is_a x "__array")
     (& (is_array x)
        (%%native "array_keys (" x ") === range (0, count (" x ") - 1)"))))

(fn %array-push (arr x)
  (%= (%%native "$" arr "[]") x)
  x)

(fn array-push (arr x)
  (? (is_a x "__array")
     (arr.p x)
     (%array-push arr x))
  x)

(fn list-array (x)
  (!= #()
    (@ (i x !)
      (!.p i))))

(fn list-phparray (x)
  (!= (%%%make-array)
    (@ (i x !)
      (%= (%%native "$" ! "[]") i))))

(fn aref (a k)
  (? (is_array a)
     (& (%aref-defined? a k)
        (%aref a k))
     (href a k)))

(fn (= aref) (v a k)
  (? (is_array a)
     (error "Native arrays cannot be modified with AREF. Please try macro =-%AREF instead.")
     (=-href v a k)))

(fn phparray-object (x)
  (%%native "(object)$" x))

(fn object-phparray (x)
  (%%native "(array)$" x))
