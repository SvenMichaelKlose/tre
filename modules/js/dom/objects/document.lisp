(var *document-body* document.body)

(fn make-extended-html-document ()
  (document-extend (document.implementation.create-h-t-m-l-document)))

(defclass tre-html-document ())

(defmember tre-html-document
    document-element
    query-selector
    query-selector-all)

(defmethod tre-html-document $? (css-selector)
  (unless (head? css-selector "<")
    (query-selector css-selector)))

(defmethod tre-html-document $* (css-selector)
  (new nodelist (get-list css-selector)))

(defmethod tre-html-document get-list (css-selector)
  (unless (head? css-selector "<")
    (array-list (query-selector-all css-selector))))

(defmethod tre-html-document get-html ()
  document-element.outer-h-t-m-l)

(defmethod tre-html-document set-html (x)
  (= document-element.inner-h-t-m-l x)
  (document-extend this)
  x)

(defmethod tre-html-document add-style (txt)
  (with (head   (document-element.$? "head")
         style  ($$ `(style :type "text/css")))
    (head.add (style.add ($$ txt)))))

(progn
  ,@(make-listener-methods 'tre-html-document))

(finalize-class tre-html-document)
