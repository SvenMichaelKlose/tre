;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate content-document content-window open close)

(defun iframe-document (x)
  (| x.content-document
     (awhen x.content-window
       !.document)
     (? (defined? x.document)
	    x.document
	    (when-debug
          (error "Don't know how to get an iframe's document in this browser. :(")))))

(defun iframe-extend (x)
  (document-extend (iframe-document x))
  x)
