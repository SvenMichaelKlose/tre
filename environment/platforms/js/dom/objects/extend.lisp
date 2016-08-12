; tré – Copyright (c) 2008,2009,2011–2013,2016 Sven Michael Klose <pixel@copei.de>

(defun dom-extend (x)
  (pcase x
    document? (hash-merge x caroshi-html-document.prototype)
    element?  (hash-merge x caroshi-element.prototype)
    text?     (& *extended-textnodes?*  ; TODO Check if this makes sense. (was text events in safari).
                 (hash-merge x *text-node.prototype))))

(defun dom-tree-extend (root)
  (!? root
      ((dom-extend !).walk #'dom-extend)))

(dont-obfuscate document document-element)

(defun document-extend (&optional (doc document))
  (dom-extend doc)
  (dom-tree-extend doc.document-element)
  doc)
