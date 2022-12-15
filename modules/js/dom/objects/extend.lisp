(fn element-extend (x)
  (js-merge-props! x tre-element.prototype))

(fn dom-extend (x)
  (pcase x
    document? (js-merge-props! x tre-html-document.prototype)
    element?  (element-extend x)
    text?     (js-merge-props! x *text-node.prototype)))

(fn dom-tree-extend (root)
  (!? root
      ((dom-extend !).walk #'dom-extend)))

(fn document-extend (&optional (doc document))
  (dom-extend doc)
  (dom-tree-extend doc.document-element)
  doc)
