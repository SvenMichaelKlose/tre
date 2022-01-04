(define-filter dom2lml-children #'dom2lml)

; TODO: Translate keyword back from camel case.
(fn dom2lml-attributes (x)
  (mapcan [`(,(make-keyword (upcase _.)) ,._)]
          x))

(fn dom2lml-element (x)
  (unless (eql (symbol-name nil) x.tag-name)
    `(,(make-symbol (upcase x.tag-name))
      ,@(!? (x.attributes-alist)
            (dom2lml-attributes !))
      ,@(!? (x.child-list)
            (dom2lml-children !)))))

(fn dom2lml-text-node (x)
  (& x x.node-value))

(fn dom2lml (x)
  (? (element? x)
     (dom2lml-element x)
     (dom2lml-text-node x)))
