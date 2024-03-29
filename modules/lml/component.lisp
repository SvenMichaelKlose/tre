(var *pending-component-updates* nil)

(fn update-lml-components ()
  (awhile (progn
            (= *pending-component-updates* (unique *pending-component-updates*))
            (pop *pending-component-updates*))
          nil
    (when (| !._force-update?
             (!.component-should-update?))
      (= !._force-update? nil)
      (!.component-will-update)
      (!._rerender))))


(defclass lml-component (attrs)
  (= props attrs)
  (= state {})
  (= _force-update? nil))

(defmember lml-component
    element
    props
    state
    _force-update?)

(defmethod lml-component component-will-mount ())
(defmethod lml-component component-did-mount ())
(defmethod lml-component component-should-update? () t)
(defmethod lml-component component-will-update ())
(defmethod lml-component render ())

(defmethod lml-component _rerender ()
  (= element (? element.parent-node
                (element.replace-by ($$ (render)))
                ($$ (render)))))

(defmethod lml-component _schedule-update ()
  (push this *pending-component-updates*)
  (wait #'update-lml-components 0))

(defmethod lml-component _unschedule-update ()
  (remove! this *pending-component-updates*))

(defmethod lml-component force-update ()
  (= _force-update? t)
  (_schedule-update))

(defmethod lml-component set-state (x)
  (@ (n (keys x))
    (= (aref state n) (aref x n)))
  (_schedule-update)
  state)

(defmethod lml-component replace-state (x)
  (= state x)
  (_schedule-update)
  state)

(defmethod lml-component init ()
  (= element ($$ (render))))

(defmethod lml-component close ()
  (_unschedule-update)
  (element.remove))

(finalize-class lml-component)


(var *lml-components* nil)

(defmacro declare-lml-component (name)
  (declare type symbol name)
  `(acons! ',name [new ,name _] *lml-components*))

(fn lml-component-name? (x)
  (assoc-value x *lml-components*))

(fn make-lml-component (name props)
  (!? (assoc-value name *lml-components*)
      (!= ($$ (~> ! props))
        (? (element? !)
           !
           (!.init)))))
