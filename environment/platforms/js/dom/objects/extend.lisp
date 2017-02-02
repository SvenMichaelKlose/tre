(fn element-extend (x)
  (hash-merge x caroshi-element.prototype))

(fn dom-extend (x)
  (pcase x
    document? (hash-merge x caroshi-html-document.prototype)
    element?  (element-extend x)
    text?     (hash-merge x *text-node.prototype)))

(fn dom-tree-extend (root)
  (!? root
      ((dom-extend !).walk #'dom-extend)))

(fn document-extend (&optional (doc document))
  (dom-extend doc)
  (dom-tree-extend doc.document-element)
  doc)
