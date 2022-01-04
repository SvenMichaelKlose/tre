(defmacro with-canvas-context (type ctx elm &rest body)
  `(let ,ctx ((slot-value ,elm 'get-context) ,type)
     ,@body))

(fn make-canvas (&optional (attributes nil) (style nil) (type "2d"))
  (alet (make-extended-element "canvas" attributes style)
    (with-canvas-context type ctx !
      (values ! ctx))))

(fn get-canvas-by-class-name (name &key (html-document docuemnt) (type "2d"))
  (alet (html-document.get (+ "." name))
    (with-canvas-context type ctx !
      (values ! ctx))))
