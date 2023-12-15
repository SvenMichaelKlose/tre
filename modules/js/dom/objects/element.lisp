; TODO: remove READ-ATTRIBUTE.
; TODO: ATTR as short-cut for getAttribute()

(fn tre-ancestor-or-self-if (node pred)
  (ancestor-or-self-if node pred))

(fn make-native-element (name doc ns)
  (? (& ns (defined? doc.create-element-n-s))
     (doc.create-element-n-s ns name)
     (doc.create-element name)))

(fn make-extended-element (name &optional (attrs nil) (style nil) &key (doc document) (ns nil))
  (aprog1 (make-native-element name doc ns)
    (js-merge-props! ! tre-element.prototype)
    (!.write-attributes attrs)
    (!.set-styles style)))

(defclass (tre-element visible-node) ())

(defmember tre-element
    append-child
    attributes
    child-nodes
    children
    class-name
    class-list
    first-child
    set-attribute get-attribute remove-attribute
    get-elements-by-class-name
    get-elements-by-tag-name
    has-child-nodes
    inner-h-t-m-l
    style
    tag-name
    width height
    offset-width offset-height
    offset-left offset-right
    offset-top offset-bottom
    offset-parent
    owner-document
    query-selector
    query-selector-all
    _tre-rotation)

(defmethod tre-element child-list ()
  (array-list child-nodes))

(defmethod tre-element remove-children ()
  (do-children (x this this)
    (x.remove)))

(defmethod tre-element add (x)
  (?
    (cons? x)
      (dolist (i x this)
        (add i))
    (array? x)
      (doarray (i x this)
        (add i))
    (append-child x))
  this)

(defmethod tre-element add-front (child)
  (& child
     (? first-child
        (first-child.add-before child)
        (append-child child)))
  this)

(defmethod tre-element attr (name, value)
  (? (not value)
     (get-attribute name)
     (write-attribute name value)))

(defmethod tre-element attr? (name)
  (has-attribute name))

(defmethod tre-element attrs (new-attrs)
  (? new-attrs
     (? (hash-table? attrs)
        (maphash #'((k v)
                     (write-attribute k v))
                 attrs)
        (@ (i attrs)
          (write-attribute i. .i)))
     (let attrs (make-hash-table)
       (doarray (a attributes attrs)
         (= (href attrs a.node-name) a.node-value)))))

(defmethod tre-element set-styles (styles)
  (maphash #'((k v)
               (set-style k v))
           styles)
  styles)

(defmethod tre-element remove-styles ()
  (remove-attribute "style"))

(defmethod tre-element set-style (k v)
  (= (aref style k) v))

(defmethod tre-element get-style (x)
  (| (aref style x)
     (aref (document.default-view.get-computed-style this nil) x)))

(defmethod tre-element show () (set-style "display" ""))
(defmethod tre-element hide () (set-style "display" "none"))

; TODO: Remove.  Replace by CSS animation where required. (pixel)
(defmethod tre-element set-opacity (x)
  (? (== 1 x)
     (& (defined? style.remove-property)
        (style.remove-property "opacity"))
     (set-style "opacity" x))
  x)

;; Set absolute position relative to browser window.
(defmethod tre-element set-position (x y)
  (set-styles (new "left" (+ x "px")
                   "top"  (+ y "px")))
  this)

(defmethod tre-element cumulative-offsets ()
  (? (eql this.style.position "absolute")
     #((!= this.style.left
         (integer (subseq ! 0 (- (length !) 2))))
       (!= this.style.top
         (integer (subseq ! 0 (- (length !) 2)))))
     (do ((x 0)
          (y 0)
          (i this i.offset-parent))
         ((not i) #(x y))
       (+! x i.offset-left)
       (+! y i.offset-top))))

(defmethod tre-element get-position-x ()
  (aref (cumulative-offsets) 0))

(defmethod tre-element get-position-y ()
  (aref (cumulative-offsets) 1))

(defmethod tre-element get-width ()
  (alet (| (? (< 0 offset-width)
              offset-width
              width)
           0)
    (& (number? !)
       !)))

(defmethod tre-element get-height ()
  (alet (| (? (< 0 offset-height)
              offset-height
              height)
           0)
    (& (number? !)
       !)))

(defmethod tre-element set-width (x)
  (set-style "width" (+ x "px"))
  x)

(defmethod tre-element set-height (x)
  (set-style "height" (+ x "px"))
  x)

(defmethod tre-element inside-x? (x)
  (within? x (get-position-x) (get-width)))

(defmethod tre-element inside-y? (y)
  (within? y (get-position-y) (get-height)))

(defmethod tre-element inside? (x y)
  (& (inside-y? y)
     (inside-x? x)))

(defmethod tre-element find-element-at (x y)
  (do-children (i this this)
    (& (element? i)
       (i.inside? x y)
       (return (| (i.find-element-at x y)
                  this)))))

(defmethod tre-element from-point (x y)
  (& (inside? x y)
     (? (& (element? this)
           first-child)
        (do-children (i this)
          (!? (i.seek-element x y)
              (return !)))
        this)))

(defmethod tre-element is? (css-selector)
  (!= (| parent-node owner-document)
    (member this (array-list (!.query-selector-all css-selector)))))

(defmethod tre-element $? (css-selector)
  (? (head? css-selector "<")
     (ancestor-or-self (subseq css-selector 1))
     (query-selector css-selector)))

(defmethod tre-element $* (css-selector)
  (new nodelist (get-list css-selector)))

(defmethod tre-element get-list (css-selector)
  (array-list (query-selector-all css-selector)))

(defmethod tre-element ancestor-or-self (css-selector)
  (alet (array-list (this.owner-document.query-selector-all css-selector))
    (do ((i this i.parent-node))
        ((not i))
      (& (member i ! :test #'eq)
         (return i)))))

(defmethod tre-element ancestor (css-selector)
  (!? parent-node
      (!.ancestor-or-self css-selector)))

(defmethod tre-element ancestor-or-self-if (fun)
  (tre-ancestor-or-self-if this fun))

(defmethod tre-element get-first-child-by-class-name (name)
  (find-if [eq this _.parent-node]
           (this.get-list (+ "." name))))

(defmethod tre-element set-inner-h-t-m-l (html)
  (this.remove-children)
  (& html (= inner-h-t-m-l html))
  (dom-tree-extend this))

(defmethod tre-element get-child-at (idx)
  (assert (integer<= 0 idx) (+ "tre-element get-child-at " idx " is not a positive integer"))
  (let x first-child
    (while (< 0 idx)
           x
      (--! idx)
      (= x x.next-sibling))))

(defmethod tre-element blank? ()
  (& (empty-string? text-content)
     (do-children (i this t)
       (& (element? i)
          (return nil)))))

(defmethod tre-element on (name fun)
  (this.add-event-listener name fun))

(finalize-class tre-element)
