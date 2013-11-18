;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun copy-iframe-to-document (iframe html-document &key (remove-if t))
  (let from-doc (iframe-document iframe)
    (document-extend from-doc)
    (copy-head-and-body (iframe-document iframe) html-document :remove-if remove-if))
  (document-extend html-document))
