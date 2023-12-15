(define-filter dom2lml-children #'dom2lml)

(fn dom2lml-attributes (x)
  (maphash #'((k v)
               `(,(make-keyword (upcase k)) ,v)]
          x)))

(fn dom2lml-element (x)
  (unless (eql (symbol-name nil) x.tag-name)
    `(,(make-symbol (upcase x.tag-name))
      ,@(!? (x.attrs)
            (dom2lml-attributes !))
      ,@(!? (x.child-list)
            (dom2lml-children !)))))

(fn dom2lml-text-node (x)
  (& x x.node-value))

(fn dom2lml (x)
  (? (element? x)
     (dom2lml-element x)
     (dom2lml-text-node x)))
