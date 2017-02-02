(fn iframe-document (x)
  (| x.content-document
     (awhen x.content-window
       !.document)
     (? (defined? x.document)
	    x.document
	    (error "Don't know how to get an iframe's document in this browser. :("))))

(fn iframe-extend (x)
  (document-extend (iframe-document x))
  x)
