; tré – Copyright (c) 2010–2012,2016 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate window document body scroll)

(defun disable-scrollbars (&optional (win window))
  (win.document.body.set-style "overflow" "hidden")
  (let doc win.document
    (& doc.body.scroll
	   (= doc.body.scroll "no"))))

(defun enable-scrollbars (&optional (win window))
  (win.document.body.set-style "overflow" "visible")
  (let doc win.document
    (& doc.body.scroll
	   (= doc.body.scroll "yes"))))
