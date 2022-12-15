(defclass bnode (k v p)
  (= key k
     value v
     parent p)
  (clr left
       right)
  this)

(defmember bnode
  left
  right
  parent
  key
  value)

(defmethod bnode _add-left (k v)
  (!? left
      (!.add k v)
      (= left (new bnode k v this))))

(defmethod bnode _add-right (k v)
  (!? right
      (!.add k v)
      (= right (new bnode k v this))))

(defmethod bnode add (k v)
  (? (< k key)
     (_add-left k v)
     (_add-right k v)))

(defmethod bnode _lookup-left (k)
  (!? left
      (!.lookup k)))

(defmethod bnode _lookup-right (k)
  (!? right
      (!.lookup k)))

(defmethod bnode lookup (k)
  (? (== key k)
     this
     (? (< k key )
        (_lookup-left k)
        (_lookup-right k))))

(defmethod bnode get-first ()
  (!? left
      (!.get-first)
      this))

(defmethod bnode _next-parent (k)
  (!? parent
      (? (eq this parent.left)
         (? (> !.key k)
            !
            (!._next-trav-right k)) ; !.key is k
         (!._next-parent k))))

(defmethod bnode _next-trav-left (k)
  (!? left
      (!._next-trav k)
      (? (> key k)
         this
         (_next-parent k))))

(defmethod bnode _next-trav-right (k)
  (!? right
      (!._next-trav k)
      (_next-parent k)))

(defmethod bnode _next-trav (k)
  (? (<= key k)
     (_next-trav-right k)
     (_next-trav-left k)))

(defmethod bnode next ()
   (_next-trav key))

(finalize-class bnode)
