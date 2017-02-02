(fn symbol-names (x &key (downcase? nil))
  (@ [? (symbol? _)
        (funcall (? downcase?
                    #'downcase
                    #'identity)
                 (symbol-name _))
        _]
     x))

(fn symbol-names-string (x &key (downcase? nil))
  (apply #'string-concat (pad (symbol-names x :downcase? downcase?) " ")))
