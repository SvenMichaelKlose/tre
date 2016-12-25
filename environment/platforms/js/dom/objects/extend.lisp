(defun element-extend (x)
  (hash-merge x caroshi-element.prototype))

(defun dom-extend (x)
  (pcase x
    document? (hash-merge x caroshi-html-document.prototype)
    element?  (element-extend x)
    text?     (& *extended-textnodes?*  ; TODO Check if this makes sense. (was text events in safari).
                 (hash-merge x *text-node.prototype))))

(defun dom-tree-extend (root)
  (!? root
      ((dom-extend !).walk #'dom-extend)))

(defun document-extend (&optional (doc document))
  (dom-extend doc)
  (dom-tree-extend doc.document-element)
  doc)
