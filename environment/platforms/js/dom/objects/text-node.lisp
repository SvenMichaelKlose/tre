;;;;; tré – Copyright (c) 2008–2010,2013 Sven Michael Klose <pixel@copei.de>

(defvar *extended-textnodes?* t)

(dont-obfuscate
	create-text-node
	node-type
	node-value)

(defclass (*text-node visible-node) (text &key (doc document))
  (let x (doc.create-text-node text)
    (hash-merge x *text-node.prototype)
	x))

(defmethod *text-node blank? ()
  (empty-string? text-content))

(finalize-class *text-node)
