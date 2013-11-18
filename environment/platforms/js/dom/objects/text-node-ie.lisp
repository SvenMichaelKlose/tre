;;;;; tré – Copyright (c) 2008–2010 Sven Michael Klose <pixel@copei.de>

(defvar *extended-textnodes?* nil)

(dont-obfuscate
	create-text-node
	node-type
	node-value)

(defclass (*text-node visible-node) (text &key (doc document))
  (doc.create-text-node text))

(defun *text-node-blank? (x)
  (empty-string? x.text-content))

(finalize-class *text-node)
