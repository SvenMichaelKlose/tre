(fn make-array (&rest dimensions)
  (!= (%%native "" "new __array ()")
    (dotimes (i dimensions. !)
      (= (aref ! i) (!? .dimensions
                        (apply #'make-array !))))))

(fn list-array (x)
  (aprog1 (%%native "" "new __array ()")
    (dolist (i x !)
      (!.p i))))

(fn array (&rest elms)
  (list-array elms))

(fn array? (x)
  (| (is_a x "__array")
     (& (is_array x)
        (%%native "array_keys ($" x ") === range (0, count ($" x ") - 1)"))))

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
