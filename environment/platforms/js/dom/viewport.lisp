; tré – Copyright (c) 2009–2010,2012,2016 Sven Michael Klose <pixel@copei.de>

; TODO: Make HTML5 style.
(defun get-viewport (&optional (win window))
  (with (x  0
		 y  0
         wd win.document
		 w  (| win.inner-width
			   wd.document-element.client-width
			   wd.body.client-width)
		 h  (| win.inner-height
			   wd.document-element.client-height
			   wd.body.client-height))
    (?
  	  wd.document-element.scroll-left
        (= x wd.document-element.scroll-left
	       y wd.document-element.scroll-top)
	  wd.body.scroll-left
        (= x document.body.scroll-left
	       y document.body.scroll-top)
	  win.page-x-offset
        (= x win.page-x-offset
		   y win.page-y-offset))
	(values x y w h)))

(defun set-viewport (x y &optional (win window))
  (let wd win.document
    (?
	  wd.document-element.scroll-left
        (= wd.document-element.scroll-left x
	       wd.document-element.scroll-top y)
      wd.body.scroll-left
        (= document.body.scroll-left x
	       document.body.scroll-top y)
	    win.page-x-offset
        (= win.page-x-offset x
		   win.page-y-offset y))))

(defun adjust-viewport (elm)
  (with ((x y w h) (get-viewport)
         xr        (+ x w)
         yb        (+ y h)
         cx        (elm.get-position-x)
         cy        (elm.get-position-y)
         cxr       (+ cx (elm.get-width))
         cyb       (+ cy (elm.get-height)))
    (when (| (< (- cx 8) x)
             (< (- cy 8) y)
             (< xr (+ cxr 8))
             (< yb (+ cyb 8)))
      (elm.scroll-into-view))))

(defvar *old-viewport-width* 0)
(defvar *old-viewport-height* 0)

(defun viewport-changed? ()
  (with ((x y w h) (get-viewport))
    (prog1 (not (& (== *old-viewport-width* w)
                   (== *old-viewport-height* h)))
      (= *old-viewport-width* w)
      (= *old-viewport-height* h))))
