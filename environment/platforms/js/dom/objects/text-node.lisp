(defvar *extended-textnodes?* t)

(defclass (*text-node visible-node) (text &key (doc document))
  (let x (doc.create-text-node text)
    (hash-merge x *text-node.prototype)
	x))

(defmethod *text-node blank? ()
  (empty-string? text-content))

(finalize-class *text-node)
