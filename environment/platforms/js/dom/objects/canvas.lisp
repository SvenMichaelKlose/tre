(defmacro with-canvas-context (type ctx elm &rest body)
  `(let ,ctx ((slot-value ,elm 'get-context) ,type)
     ,@body))

(defun make-canvas (&optional (attributes nil) (style nil) (type "2d"))
  (let can (new *element "canvas" attributes style)
    (with-canvas-context type ctx can
      (values can ctx))))

(defun get-canvas-by-class-name (name &key (html-document docuemnt) (type "2d"))
  (let can (html-document.get (+ "." name))
    (with-canvas-context type ctx can
      (values can ctx))))
