; tré – Copyright (c) 2008–2016 Sven Michael Klose <pixel@copei.de>

(defvar *attribute-xlat*
  (new "class" "className"))

(defvar *attribute-xlat-rev* (make-hash-table))

(defun make-attribute-xlat ()
  (maphash #'((k v)
		        (= (aref *attribute-xlat-rev* v) k)
		        (= (aref *attribute-xlat-rev* (downcase v)) k))
	   	   *attribute-xlat*))
(make-attribute-xlat)

(defun xlat-attribute (x)
  (aref *attribute-xlat* x))

(defun make-native-element (name doc ns)
  (? (& ns (defined? doc.create-element-n-s))
     (doc.create-element-n-s ns name)
     (doc.create-element name)))

(defun *element (name &optional (attrs nil) (style nil) &key (doc document) (ns nil))
  (aprog1 (make-native-element name doc ns)
	(hash-merge ! caroshi-element.prototype)
    (!.write-attributes attrs)
	(!.set-styles style)))

(defclass (caroshi-element visible-node) ())

(defmember caroshi-element
    append-child
	attributes
	child-nodes
	children
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
    _caroshi-rotation)

(defmethod caroshi-element child-array ()
  this.child-nodes)

(defmethod caroshi-element child-list ()
  (array-list child-nodes))

(defmethod caroshi-element remove-children ()
  (do-children (x this this)
	(? (element? x)
       (x.remove)
	   (x.remove-without-listeners))))

(defmethod caroshi-element remove-children-without-listeners ()
  (do-children (x this this)
    (x.remove-without-listeners)))

(defmethod caroshi-element add (child)
  (& child
     (append-child child))
  this)

(defmethod caroshi-element add-array (x)
  (assert (array? x) "add-arraxy: array expected")
  (doarray (i x this)
    (add i)))

(defmethod caroshi-element add-list (x)
  (@ (i x this)
    (add i)))

(defmethod caroshi-element add-front (child)
  (& child
	 (? first-child
        (first-child.add-before child)
	    (append-child child)))
  this)

(defmethod caroshi-element move-front ()
  (& this.next-sibling
     (parent-node.add-front this))
  this)

(defmethod caroshi-element move-back ()
  (& this.next-sibling
     (parent-node.add this))
  this)

(defmethod caroshi-element add-element (name attrs)
  (add (new *element name attrs)))

(defmethod caroshi-element add-text (text)
  (add (new *text-node text)))

; XXX last-child-BY-class
(defmethod caroshi-element last-child-of-class (cls)
  (with (elm nil
		 chlds (child-array))
	(doarray (x chlds elm)
	  (& (string== cls (x.get-class))
		 (= elm x)))))

(defmethod caroshi-element read-attribute (name)
  (declare type string name)
  (| (awhen (xlat-attribute name)
       (get-attribute !))
     (get-attribute name)))

(defmethod caroshi-element read-attributes ()
  (let attrs (make-hash-table)
    (doarray (a attributes attrs)
      (= (href attrs (| (aref *attribute-xlat-rev* a.node-name)
			  		    a.node-name))
	     a.node-value))))

(defmethod caroshi-element attributes-alist ()
  (let attrs (make-queue)
    (doarray (a attributes (queue-list attrs))
	    (enqueue attrs (. (| (aref *attribute-xlat-rev* a.node-name)
				  		     a.node-name)
			              a.node-value)))))

(defmethod caroshi-element has-attribute? (name)
  (doarray (a attributes)
	(& (string== a.node-name name)
	   (return t))))

(defmethod caroshi-element attribute-value? (name val)
  (& (has-attribute? name)
     (string== (downcase (read-attribute name))
               (downcase val))))

(defmethod caroshi-element write-attribute (name value)
  (set-attribute name value)
  (awhen (xlat-attribute name)
    (set-attribute ! value))
  value)

(defmethod caroshi-element write-attributes (attrs)
  (maphash #'((k v)
				(write-attribute k v))
           attrs)
  attrs)

(defmethod caroshi-element remove-attributes (attrs)
  (adolist attrs
    (remove-attribute !)))

(defmethod caroshi-element has-name-attribute? ()
  (has-attribute? "name"))

(defmethod caroshi-element has-name? (x)
  (member (downcase (get-name)) (@ #'downcase (ensure-list x)) :test #'string==))

(defmethod caroshi-element get-name ()
  (read-attribute "name"))

(defmethod caroshi-element set-name (x)
  (write-attribute "name" x))

(defmethod caroshi-element class? (x)
  (!? (read-attribute "class")
      (let c (+ " " ! " ")
        (adolist ((ensure-list x))
          (& (< -1 (c.index-of (+ " " ! " ")))
             (return t))))))

(defmethod caroshi-element get-class ()
  (read-attribute "class"))

(defmethod caroshi-element get-classes ()
  (split #\  (get-class) :test #'character==))

(defmethod caroshi-element set-class (x)
  (write-attribute "class" x))

(defmethod caroshi-element add-class (x)
  (let classes (get-classes)
	(unless (member x classes :test #'string==)
      (set-class (concat-stringtree
				     (pad (+ classes (list x))
					   	  " "))))))

(defmethod caroshi-element add-classes (x)
  (@ (i x x)
    (add-class i)))

(defun remove-string== (x lst)
  (remove x lst :test #'string==))

(defmethod caroshi-element remove-class (x)
  (? (cons? x)
     (adolist x
       (remove-class !))
     (set-class (apply #'string-concat (pad (remove-string== x (get-classes)) " ")))))

(defmethod caroshi-element set-id (id)
  (? id
     (write-attribute "id" id)
     (remove-attribute "id")))

(defmethod caroshi-element get-id (id)
  (!? (read-attribute "id")
	  (unless (empty-string? !)
	    (number !))))

(defmethod caroshi-element tag-name? (n)
  (? (cons? n)
     (member-if [tag-name? _] n)
     (member (downcase tag-name) (@ #'downcase (ensure-list n)) :test #'string==)))

(defmethod caroshi-element set-styles (styles)
  (maphash #'((k v)
               (set-style k v))
	       styles)
  styles)

(defmethod caroshi-element remove-styles ()
  (remove-attribute "style"))

(defmethod caroshi-element set-style (k v)
  (= (aref style k) v))

(defmethod caroshi-element get-style (x)
  (declare type string x)
  (| (aref style x)
     (aref (document.default-view.get-computed-style this nil) x)))

(defmethod caroshi-element show ()
  (set-style "display" ""))

(defmethod caroshi-element hide ()
  (set-style "display" "none"))

(defmethod caroshi-element get-opacity ()
  (number (get-style "opacity")))

(defmethod caroshi-element set-opacity (x)
  (? (integer== 1 x)
     (& (defined? style.remove-property)
	    (style.remove-property "opacity"))
     (set-style "opacity" x))
  (alet (/ 1 1000) ; TODO Floating point bug in PRINT.
    (= this.style.filter (+ "alpha(opacity=" (* (? (< x !) ! x) 100) ")")))
  x)

(defmethod caroshi-element set-rotation (x)
  (alet (mod x 360)
    (= _caroshi-rotation x)
    (@ (i '("" "-webkit-" "-moz-" "-o-") x)
      (set-style (+ i "transform") (+ "rotate(" ! "deg)")))))

(defmethod caroshi-element get-rotation ()
  _caroshi-rotation)

;; Set absolute position relative to browser window.
(defmethod caroshi-element set-position (x y)
  (declare type number x y)
  (set-styles (new "left" (+ x "px")
                   "top"  (+ y "px")))
  this)

(defmethod caroshi-element cumulative-offset ()
  (? (eql this.style.position "absolute")
     (make-array (alet this.style.left
                   (integer (subseq ! 0 (- (length !) 2))))
                 (alet this.style.top
                   (integer (subseq ! 0 (- (length !) 2)))))
     (do ((x 0)
	      (y 0)
	      (i this i.offset-parent))
         ((not i) (make-array x y))
       (+! x i.offset-left)
       (+! y i.offset-top))))

(defmethod caroshi-element get-position-x ()
  (aref (cumulative-offset) 0))

(defmethod caroshi-element get-position-y ()
  (aref (cumulative-offset) 1))

(defmethod caroshi-element get-width ()
  (alet (| (? (< 0 offset-width)
	          offset-width
	          width)
           0)
    (& (number? !)
       !)))

(defmethod caroshi-element get-height ()
  (alet (| (? (< 0 offset-height)
              offset-height
              height)
           0)
    (& (number? !)
       !)))

(defmethod caroshi-element set-width (x)
  (set-style "width" (+ x "px"))
  x)

(defmethod caroshi-element set-height (x)
  (set-style "height" (+ x "px"))
  x)

(defmethod caroshi-element inside-x? (x)
  (within? x (get-position-x) (get-width)))

(defmethod caroshi-element inside-y? (y)
  (within? y (get-position-y) (get-height)))

(defmethod caroshi-element inside? (x y)
  (& (inside-y? y)
     (inside-x? x)))

(defmethod caroshi-element find-element-at (x y)
  (do-children (i this this)
    (dom-extend i)
	(& (element? i)
	   (i.inside? x y)
	   (return (| (i.find-element-at x y)
			  	  this)))))

(defmethod caroshi-element from-point (x y)
  (& (inside? x y)
	 (? (& (element? this)
           first-child)
	    (do-children (i this)
		  (!? (i.seek-element x y)
              (return !)))
	    this)))

(defmethod caroshi-element is? (css-selector)
  (member this (array-list ((| parent-node
                               owner-document).query-selector-all css-selector))))

(defmethod caroshi-element get (css-selector)
  (? (head? css-selector "<")
     (alet (subseq css-selector 1)
       (? (is? !)
          this
          (ancestor-or-self !)))
     (query-selector css-selector)))

(defmethod caroshi-element get-list (css-selector)
  (array-list (query-selector-all css-selector)))

(defmethod caroshi-element get-last (css-selector)
  (last (get-list css-selector)))

(defmethod caroshi-element get-nodes (css-selector)
  (new nodelist (get-list css-selector)))

(defmethod caroshi-element ancestor-or-self (css-selector)
  (alet (array-list (this.owner-document.query-selector-all css-selector))
    (do ((i this i.parent-node))
        ((not i))
      (& (member i ! :test #'eq)
         (return i)))))

(defmethod caroshi-element ancestor (css-selector)
  (!? parent-node
      (!.ancestor-or-self css-selector)))

(defmethod caroshi-element ancestor-or-self-if (fun)
  (caroshi-ancestor-or-self-if this fun))

(defmethod caroshi-element get-first-child-by-class-name (name)
  (find-if [eq this _.parent-node]
           (this.get-list (+ "." name))))

(defmethod caroshi-element set-inner-h-t-m-l (html)
  (this.remove-children)
  (& html (= inner-h-t-m-l html))
  (dom-tree-extend this))

(defmethod caroshi-element get-if (predicate)
  (with-queue n
    (walk [& (element? _)
             (funcall predicate)
             (enqueue n _)])
    (queue-list n)))

(defmethod caroshi-element get-child-at (idx)
  (assert (integer<= 0 idx) (+ "caroshi-element get-child-at " idx " is not a positive integer"))
  (let x first-child
    (while (< 0 idx)
		   x
	  (--! idx)
	  (= x x.next-sibling))))

(defmethod caroshi-element blank? ()
  (& (empty-string? text-content)
     (do-children (i this t)
       (& (element? i)
	      (return nil)))))

(mapcar-macro _ (remove "focus" *all-events*) ; TODO: Prefix names instead?
  `(defmethod caroshi-element ,(make-symbol (upcase _)) (fun)
     (*event-module*.hook ,_ fun this)))

(finalize-class caroshi-element)
