;;;;; tré – Copyright (c) 2009–2010,2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate
  	document
	document-element
	window
	body
  	scroll-top
	scroll-left
	page-x-offset
	page-y-offset
	inner-width
	inner-height
	client-width
	client-height)

(defun get-viewport (&optional (win window))
  (with (x 0
		 y 0
		 w (| win.inner-width
			  win.document.document-element.client-width
			  win.document.body.client-width)
		 h (| win.inner-height
			  win.document.document-element.client-height
			  win.document.body.client-height))
    (?
  	  win.document.document-element.scroll-left
        (= x win.document.document-element.scroll-left
	       y win.document.document-element.scroll-top)
	  win.document.body.scroll-left
        (= x document.body.scroll-left
	       y document.body.scroll-top)
	  win.page-x-offset
        (= win.page-x-offset
		   win.page-y-offset))
	(values x y w h)))

(defun set-viewport (x y &optional (win window))
  (?
	win.document.document-element.scroll-left
      (= win.document.document-element.scroll-left x
	     win.document.document-element.scroll-top y)
    win.document.body.scroll-left
      (= document.body.scroll-left x
	     document.body.scroll-top y)
	win.page-x-offset
      (= win.page-x-offset x
		 win.page-y-offset y)))

(dont-obfuscate scroll-into-view)

(defun adjust-viewport (elm)
  (with ((x y w h) (get-viewport)
         xr (+ x w)
         yb (+ y h)
         cx (elm.get-position-x)
         cy (elm.get-position-y)
         cxr (+ cx (elm.get-width))
         cyb (+ cy (elm.get-height)))
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
