(defmacro with-canvas-context (type ctx elm &rest body)
  `(let ,ctx ((slot-value ,elm 'get-context) ,type)
     ,@body))

(fn make-canvas (&optional (attributes nil) (style nil) (type "2d"))
  (!= ($$ '(canvas))
    (!.attrs attributes)
    (!.css style)
    (with-canvas-context type ctx !
      (values ! ctx))))
