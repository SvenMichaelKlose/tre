(fn start-client ()
  (document-extend) ; Module "js" DOM extensions
  (document.body.add ($$ `(p "Server reply: " ,(server-apply '+ 1 2)))))

(add-onload #'start-client)
