(defun make-iframe-with-data (continuer data html-document &key (ns nil))
  (make-iframe-with-url continuer (data-url data 
                                            :typ "text"
                                            :fmt "html")
                        html-document :ns ns))
