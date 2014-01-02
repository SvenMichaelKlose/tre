;;;;; tré – Copyright (c) 2008,2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun dom-extend (x)
  (?
    (not x)       nil
    (element? x)  (progn
                    (alert x.tag-name)
                    (hash-merge x caroshi-element.prototype))
    (text? x)     (& *extended-textnodes?*
                     (hash-merge x *text-node.prototype))))

(defun dom-tree-extend (root)
  (when root
    ((dom-extend root).walk #'dom-extend)))

(dont-obfuscate document document-element)

(defun document-extend (&optional (doc document))
  (dom-tree-extend doc.document-element)
  doc)
