;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate ready-state)

(defmacro define-document-waiter (name x getter)
  `(defun ,name (continuer ,x)
     (continued nil (wait 100)
	   (let doc ,getter
	     (? (== "complete" doc.ready-state)
		    (funcall continuer)
		    (,name continuer ,x))))))

(define-document-waiter wait-until-document-ready html-document html-document)
(define-document-waiter wait-until-iframe-ready iframe (iframe-document iframe))
