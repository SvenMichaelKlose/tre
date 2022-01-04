(defclass (*text-node visible-node) (text &key (doc document))
  (let x (doc.create-text-node text)
    (js-merge-props! x *text-node.prototype)
    x))

(defmethod *text-node blank? ()
  (empty-string? text-content))

(finalize-class *text-node)
