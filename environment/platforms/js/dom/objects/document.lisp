; tré – Copyright (c) 2016 Sven Michael Klose <pixel@copei.de>

(defun make-caroshi-html-document ()
  (document-extend (document.implementation.create-h-t-m-l-document)))

(defclass caroshi-html-document ()
  this)

(defmember caroshi-html-document
    document-element
    query-selector
    query-selector-all)

(defmethod caroshi-html-document get (css-selector)
  (unless (head? css-selector "<")
    (query-selector css-selector)))

(defmethod caroshi-html-document get-list (css-selector)
  (unless (head? css-selector "<")
    (array-list (query-selector-all css-selector))))

(defmethod caroshi-html-document get-last (css-selector)
  (last (get-list css-selector)))

(defmethod caroshi-html-document get-nodes (css-selector)
  (new nodelist (get-list css-selector)))

(defmethod caroshi-html-document get-html ()
  document-element.outer-h-t-m-l)

(defmethod caroshi-html-document get-html-body ()
  document-element.body.outer-h-t-m-l)

(defmethod caroshi-html-document set-html (x)
  (= document-element.inner-h-t-m-l x)
  (document-extend this)
  x)

(defmethod caroshi-html-document set-html-body (x)
  (set-html (+ "<html>"
               "<head><meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\"></head>"
               "<body>" data "</body>"
               "</html>")))

(defmethod caroshi-html-document add-style (txt)
  (with (head   (document-element.get "head")
         style  (new *element "style" (new "type" "text/css") nil :doc this))
    (head.add (style.add-text txt))))

(finalize-class caroshi-html-document)
