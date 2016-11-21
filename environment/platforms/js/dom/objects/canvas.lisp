;;;;; Caroshi – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate get-context
                translate
                fill-style fill-rect
                begin-path close-path
                move-to line-to
                fill stroke draw-image
                transform set-transform
                clip
                save restore
                image-smoothing-enabled moz-image-smoothing-enabled)

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
