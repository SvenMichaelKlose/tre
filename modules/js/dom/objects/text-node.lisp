(defclass (*text-node visible-node) (text &key (doc document))
  (return (doc.create-text-node text)))

(defmethod *text-node blank? ()
  (empty-string? text-content))

(finalize-class *text-node)
