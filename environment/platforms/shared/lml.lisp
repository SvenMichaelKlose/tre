(fn string-or-cons? (expr)
  (| (string? expr) (cons? expr)))

(fn lml-get-children (x)
  (& (cons? x)
     (? (cons? x.)
        x
        (lml-get-children .x))))

(fn lml-get-attribute (x name)
  (& x
     (unless (cons? x.)
       (? (eq name x.)
          (cadr x)
          (lml-get-attribute .x name)))))

(fn lml-child? (expr)
  (string-or-cons? expr))

(fn string-or-empty-string (x)
  (? x (string x) ""))

(fn lml-attr-string (x)
  (& (cons? x) (error "Cannot take cons as a LML attribute."))
  (downcase (string-or-empty-string x)))

(fn lml-attr-value-string (x)
  (? (string? x)
	 x
     (lml-attr-string x)))
