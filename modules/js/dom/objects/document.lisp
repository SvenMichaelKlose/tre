(var *document-body* document.body)

(fn make-extended-html-document ()
  (document-extend (document.implementation.create-h-t-m-l-document)))

(defclass tre-html-document ()
  this)

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

;(defmethod tre-html-document get-last (css-selector)
;  (last (get-list css-selector)))

(defmethod tre-html-document get-html ()
  document-element.outer-h-t-m-l)

(defmethod tre-html-document set-html (x)
  (= document-element.inner-h-t-m-l x)
  (document-extend this)
  x)

;(defmethod tre-html-document get-html-body ()
;  document-element.body.outer-h-t-m-l)

;(defmethod tre-html-document set-html-body (x)
;  (set-html (+ "<html>"
;               "<head><meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\"></head>"
;               "<body>" data "</body>"
;               "</html>")))

(defmethod tre-html-document add-style (txt)
  (with (head   (document-element.$? "head")
         style  (make-extended-element "style" (new "type" "text/css") nil :doc this))
    (head.add (style.add-text txt))))

(progn
  ,@(@ [`(defmethod tre-html-document ,(make-symbol (upcase _)) (fun)
           (this.add-event-listener ,_ fun))]
       *all-events*))

(finalize-class tre-html-document)
