(var *base-url* (window-directory-path))
(var *server-url* (path-append *base-url* "server.php"))
(var *http-funcall-error* [dump "HTTP-FUNCALL error"])

(fn expr2xml (x)
  (? x
     (!= (make-extended-element "div")
       (expr2dom ! x)
       !.inner-h-t-m-l)
     ""))

(fn xml2expr (x)
  (unless (empty-string-or-nil? x)
    (!= (make-extended-element "div")
      (!.set-inner-h-t-m-l x)
      (dom2expr !.first-child))))

(fn send-http-funcall (data)
  (xml2expr (http-request *server-url*
                          (list (. "q" (expr2xml data)))
                          :onerror #'http-request-error)))

(defmacro declare-server-command (name argdef)
  (print-definition `(declare-server-command ,name ,argdef))
  `(fn ,name ,argdef
     (send-http-funcall (list ',name ,@(argument-expand-names 'http-funcall argdef)))))
