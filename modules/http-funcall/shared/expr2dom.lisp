(fn expr2props (x)
  (when x
    (alist-props
      (?
        (| (number? x)
           (string? x)
           (json-object? x))
          (list (. "t" "u")
                (. "v" x))
        (cons? x)
          (list (. "t" "c")
                (. "a" (expr2props x.))
                (. "d" (expr2props .x)))
        (array? x)
          (list (. "t" "a")
                (. "v" (expr2props (array-list x))))
        (symbol? x)
          (list (. "t" "y")
                (. "p" (keyword? x))
                (. "v" (symbol-name x)))
        t))))

(fn props2expr (x)
  (when x
    (case x.t :test #'string==
      "u"  x.v
      "c"  (. (props2expr x.a)
              (props2expr x.d))
      "a"  (list-array (props2expr x.v))
      "y"  (make-symbol x.v (& (eql ":" x.p)
                               *keyword-package*))
      t)))
