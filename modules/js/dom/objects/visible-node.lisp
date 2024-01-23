(fn clone-element-array (x)
  (!= #()
    (doarray (i x !)
      (!.push (i.clone t)))))

(defclass visible-node ())

(defmember visible-node
    parent-node
    next-sibling
    previous-sibling
    clone-node
    insert-before
    remove-child
    text-content)

(defmethod visible-node clone (children?)
  (dom-tree-extend (clone-node children?)))

(defmethod visible-node remove ()
  (& (element? this)
     (this.attr? "debugonremove")
     (invoke-debugger))
  (!? parent-node
      (!.remove-child this)))

(defmethod visible-node add-before (new-elm)
  (@ (i (ensure-list new-elm))
    (parent-node.insert-before i this))
  new-elm)

(defmethod visible-node add-after (new-elm)
  (let to this
    (@ (i (ensure-list new-elm))
      (!? to.next-sibling
          (!.add-before i)
          (parent-node.add i))
      (= to i)))
  new-elm)

(defmethod visible-node insert-next-to (new-elm after?)
  (? after?
     (add-after new-elm)
     (add-before new-elm)))

(defmethod visible-node walk (fun)
  (declare type function fun)
  (& (not (eq 'next-sibling (funcall fun this)))
     (element? this)
     (doarray (x this.child-nodes this)
       (element-extend x)
       (x.walk fun)))
  this)

(defmethod visible-node self-and-next ()
  (do ((arr #())
       (x this x.next-sibling))
      ((not x) arr)
    (arr.push x)))

(defmethod visible-node remove-self-and-next ()
  (doarray (i (self-and-next))
    (i.remove)))

(defmethod visible-node split-before ()
  (with (div        parent-node
         new-elm    (div.clone nil))
    (new-elm.add (clone-element-array (self-and-next)))
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

(defmethod visible-node update (o n)
  ; TODO: Make proper.
  (& o n
     (? (o.is-equal-node n))
        (o.first-child.update n.first-child)
        (o.replace-by n)))

(finalize-class visible-node)
