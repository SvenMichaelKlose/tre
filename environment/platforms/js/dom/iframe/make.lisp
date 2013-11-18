;;;;; tré – Copyright (c) 2010–2011,2013 Sven Michael Klose <pixel@copei.de>

(defun make-iframe (html-document &key (ns nil))
  (let i (new *element "iframe" :ns ns :doc html-document)
    (i.hide)
	(html-document.body.add-front i)
	(iframe-extend i)))
