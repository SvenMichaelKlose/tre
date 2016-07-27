; tré – Copyright (c) 2008–2013,2015 Sven Michael Klose <pixel@copei.de>

(defun visible-node-insert-before (elm new-elm)
  (@ (i (ensure-list new-elm))
    (!? *dom-callback-before-insert-before*
	    (funcall ! elm))
    (elm.parent-node.insert-before i elm))
  new-elm)

(defun visible-node-walk (n fun)
  (declare type function fun)
  (& (not (eq 'next-sibling (funcall fun n)))
     (element? n)
     (doarray (x (caroshi-element-children-array n) n)
       (visible-node-walk x fun)))
  n)

(defun visible-node-remove-without-listeners-or-callbacks (n)
  (n.parent-node.remove-child n))

(defclass visible-node ())

,(let n '(parent-node
		  next-sibling
		  previous-sibling
		  clone-node
		  insert-before
		  remove-child
		  text-content)
   `(progn
	  (defmember visible-node ,@n)
	  (dont-obfuscate ,@n)))

(defmember visible-node
  _unhooks)

(defmethod visible-node clone (children?)
  (dom-tree-extend (clone-node children?)))

(defmethod visible-node remove-without-listeners-or-callbacks ()
  (visible-node-remove-without-listeners-or-callbacks this))

(defvar *dom-callback-before-remove* nil)

(defmethod visible-node remove-without-listeners ()
  (!? *dom-callback-before-remove*
	  (funcall ! this))
  (remove-without-listeners-or-callbacks))

(defvar *dom-callback-before-insert-before* nil)

(defmethod visible-node add-before (new-elm)
  (visible-node-insert-before this new-elm))

(defmethod visible-node add-after (new-elm)
  (let to this
    (dolist (i (ensure-list new-elm))
      (!? to.next-sibling
	      (visible-node-insert-before ! i)
          (parent-node.add i))
      (= to i)))
  new-elm)

(defmethod visible-node insert-next-to (new-elm after?)
  (? after?
	 (add-after new-elm)
	 (add-before new-elm)))

(defmethod visible-node move-to (new-parent)
  (remove-without-listeners-or-callbacks)
  (new-parent.add this)
  this)

(defmethod visible-node walk (fun)
  (visible-node-walk this fun))

(defmethod visible-node remove ()
  (& (element? this)
	 (caroshi-element-remove-children this))
  (adolist _unhooks
    (funcall ! this))
  (remove-without-listeners)
  this)

(defmethod visible-node self-and-next ()
  (do ((arr (make-array))
	   (x this x.next-sibling))
	  ((not x) arr)
	(arr.push x)))

(defmethod visible-node remove-self-and-next ()
  (doarray (i (self-and-next))
	(i.remove)))

(defmethod visible-node split-before ()
  (with (div		parent-node
   		 new-elm	(div.clone nil))
	(new-elm.add-array (clone-element-array (self-and-next)))
    (remove-self-and-next)
  	(div.add-after new-elm)))

(defmethod visible-node split-up-unless (predicate)
  (let new-elm (split-before)
	(? (| (not new-elm)
		  (funcall predicate new-elm.parent-node))
	   new-elm
	   (new-elm.split-up-unless predicate))))

(defmethod visible-node replace-by (new-elm)
  (parent-node.replace-child new-elm this)
  new-elm)

(defmethod visible-node find-last-leaf ()
  (? (element? this)
	 (!? this.first-child
	      (do ((x ! x.next-sibling)
	           (top nil))
              ((not x) (| top this))
            (!? (x.find-last-leaf)
	            (= top !)))
	  this)))

(defmethod visible-node alone? ()
  (not (| previous-sibling next-sibling)))

(defmethod visible-node get-index ()
  (with (x    this
		 idx  0)
	(while x.previous-sibling
		   idx
	  (++! idx)
	  (= x x.previous-sibling))))

(defmethod visible-node get-document ()
  (alet this
    (while (not (document? !))
           !
      (| !.parent-node
         (return nil))
      (= ! !.parent-node))))

(finalize-class visible-node)
