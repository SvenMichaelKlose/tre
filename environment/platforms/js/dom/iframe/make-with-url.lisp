; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate onload)

(defun make-iframe-with-url (continuer url html-document &key (ns nil))
  (let iframe (make-iframe html-document :ns ns)
    (= iframe.onload #'(()
                         (clr iframe.onload)
                         (iframe-extend iframe)
                         (funcall continuer iframe)))
    (iframe.write-attribute "src" url)))
