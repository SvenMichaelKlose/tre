;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate window document body scroll)

(defun disable-scrollbars (&optional (win window))
  (let doc win.document
    (caroshi-element-set-style win.document.body "overflow" "hidden")
    (when doc.body.scroll
	  (= doc.body.scroll "no"))))

(defun enable-scrollbars (&optional (win window))
  (let doc win.document
    (caroshi-element-set-style win.document.body "overflow" "visible")
    (when doc.body.scroll
	  (= doc.body.scroll "yes"))))
