(var *server-commands* (make-hash-table))
(var document (new *d-o-m-document))

(defmacro declare-server-command (name args &rest body)
  (print-definition `(declare-server-command ,name ,args))
  (with-gensym g
    (!=  (argument-expand-names 'declare-server-command-implementation args)
      `(progn
         (fn ,g ,!
           ((%%native ,(compiled-function-name name)) ,@!))
         (= (href *server-commands* ',name) #',g)))))

(fn serve-http-funcall ()
  (with (without-xml-type #'((x)
                              (array_shift x)
                              (implode x))
         expr2xml #'((x)
                      (? x
                         (!= (new *d-o-m-document)
                           (expr2dom ! x !)
                           (!.save-x-m-l))
                         ""))
         xml2expr #'((x)
                      (unless (empty-string-or-nil? x)
                        (!= (new *d-o-m-document)
                          (!.load-x-m-l x)
                          (dom2expr !.first-child)))))
    (header "Content-Type: text/plain")
    (!= (xml2expr (%aref *_post* "q"))
      (%= nil (echo (without-xml-type (explode (%%native "\"\\n\"")
                                               (expr2xml (*> (href *server-commands* !.) .!)))))))))
