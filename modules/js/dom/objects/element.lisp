; TODO: remove READ-ATTRIBUTE.
; TODO: ATTR as short-cut for getAttribute()

(fn tre-ancestor-or-self-if (node pred)
  (ancestor-or-self-if node pred))

(defvar *attribute-xlat* (new "class" "className"))
(defvar *attribute-xlat-rev* (make-hash-table))

(fn make-attribute-xlat ()
  (maphash #'((k v)
                (= (aref *attribute-xlat-rev* v) k)
                (= (aref *attribute-xlat-rev* (downcase v)) k))
           *attribute-xlat*))
(make-attribute-xlat)

(fn xlat-attribute (x)
  (aref *attribute-xlat* x))

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

(defmethod tre-element move-front ()
  (& this.next-sibling
     (parent-node.add-front this))
  this)

(defmethod tre-element move-back ()
  (& this.next-sibling
     (parent-node.add this))
  this)

(defmethod tre-element add-element (name attrs)
  (add (make-extended-element name attrs)))

(defmethod tre-element add-text (text)
  (add (new *text-node text)))

(defmethod tre-element read-attribute (name)
  (| (!? (xlat-attribute name)
         (get-attribute !))
     (get-attribute name)))

(defmethod tre-element read-attributes ()
  (let attrs (make-hash-table)
    (doarray (a attributes attrs)
      (= (href attrs (| (aref *attribute-xlat-rev* a.node-name)
                        a.node-name))
         a.node-value))))

(defmethod tre-element attribute-names ()
  (let attrs (make-queue)
    (doarray (a attributes (queue-list attrs))
      (enqueue attrs (| (aref *attribute-xlat-rev* a.node-name)
                        a.node-name)))))

(defmethod tre-element attributes-alist ()
  (let attrs (make-queue)
    (doarray (a attributes (queue-list attrs))
      (enqueue attrs (. (| (aref *attribute-xlat-rev* a.node-name)
                           a.node-name)
                        a.node-value)))))

(defmethod tre-element attr? (name)
  (doarray (a attributes)
    (& (string== a.node-name name)
       (return t))))

(defmethod tre-element attribute-value? (name val)
  (& (attr? name)
     (string== (downcase (read-attribute name))
               (downcase val))))

(defmethod tre-element write-attribute (name value)
  (set-attribute name value)
  (!? (xlat-attribute name)
      (set-attribute ! value))
  value)

(defmethod tre-element write-attributes (attrs)
  (? (hash-table? attrs)
     (maphash #'((k v)
                  (write-attribute k v))
              attrs)
     (@ (i attrs)
       (write-attribute i. .i)))
  attrs)

(defmethod tre-element attr (name value)
  (? (defined? value)
     (write-attribute name value)
     (read-attribute name)))

(defmethod tre-element has-name? (x)
  (member (downcase (get-name)) (@ #'downcase (ensure-list x)) :test #'string==))

(defmethod tre-element get-name ()     (read-attribute "name"))
(defmethod tre-element set-name (x)    (write-attribute "name" x))
(defmethod tre-element get-class ()    class-name)
(defmethod tre-element get-classes ()  (split #\  class-name :test #'character==))
(defmethod tre-element class? (x)      (class-list.contains x))
(defmethod tre-element set-class (x)   (= class-name x))

(defmethod tre-element add-class (x)
  (class-list.add x))

(defmethod tre-element remove-class (x)
  (class-list.remove x))

(defmethod tre-element remove-classes (x)
  (@ (i x)
    (class-list.remove i)))

(defmethod tre-element set-id (id)
  (? id
     (write-attribute "id" id)
     (remove-attribute "id")))

(defmethod tre-element get-id (id)
  (!? (read-attribute "id")
      (unless (empty-string? !)
        (number !))))

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

(defmethod tre-element get-opacity ()
  (!= (get-style "opacity")
    (? (empty-string-or-nil? !)
       1
       (number (get-style "opacity")))))

(defmethod tre-element set-opacity (x)
  (? (== 1 x)
     (& (defined? style.remove-property)
        (style.remove-property "opacity"))
     (set-style "opacity" x))
  x)

(defmethod tre-element set-rotation (x)
  (alet (mod x 360)
    (= _tre-rotation x)
    (@ (i '("" "webkit" "moz" "o") x)
      (set-style (+ "-" i "-transform") (+ "rotate(" ! "deg)")))))

(defmethod tre-element get-rotation ()
  _tre-rotation)

;; Set absolute position relative to browser window.
(defmethod tre-element set-position (x y)
  (set-styles (new "left" (+ x "px")
                   "top"  (+ y "px")))
  this)

(defmethod tre-element cumulative-offset ()
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
  (aref (cumulative-offset) 0))

(defmethod tre-element get-position-y ()
  (aref (cumulative-offset) 1))

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
  (member this (array-list ((| parent-node
                               owner-document).query-selector-all css-selector))))

(defmethod tre-element $? (css-selector)
  (? (head? css-selector "<")
     (alet (subseq css-selector 1)
       (? (is? !)
          this
          (ancestor-or-self !)))
     (query-selector css-selector)))

(defmethod tre-element $* (css-selector)
  (new nodelist (get-list css-selector)))

(defmethod tre-element get-list (css-selector)
  (array-list (query-selector-all css-selector)))

;(defmethod tre-element get-last (css-selector)
;  (last (get-list css-selector)))

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

(progn
  ,@(@ [`(defmethod tre-element ,(make-symbol (upcase _)) (fun)
           (this.add-event-listener ,_ fun))]
       *all-events*))

(finalize-class tre-element)
