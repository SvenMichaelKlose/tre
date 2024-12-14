(var *base-url* (window-directory-path))
(var *server-url* (path-append *base-url* "server.php"))
(var *http-funcall-error* [dump "HTTP-FUNCALL error"])

(fn send-http-funcall (data)
  (props2expr (json-decode (http-request
      *server-url*
      (list (. "q" (json-encode (expr2props data))))
      :onerror #'http-request-error))))

(defmacro declare-server-command (name argdef)
  (print-definition `(declare-server-command ,name ,argdef))
  `(fn ,name ,argdef
     (send-http-funcall (list ',name ,@(argument-expand-names 'http-funcall argdef)))))
