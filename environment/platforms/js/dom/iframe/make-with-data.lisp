; tré – Copyright (c) 2010–2011,2013,2016 Sven Michael Klose <pixel@copei.de>

(defun make-iframe-with-data (continuer data html-document &key (ns nil))
  (make-iframe-with-url continuer (data-url data 
                                            :typ "text"
                                            :fmt "html")
                        html-document :ns ns))
