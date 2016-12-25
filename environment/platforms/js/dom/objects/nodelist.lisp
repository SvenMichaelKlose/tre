(defclass nodelist (x)
  (= _list x)
  this)

(defmember nodelist _list)

(defmethod nodelist list () _list)

(defmethod nodelist iterate (fun)
  (adolist _list
    (funcall fun !)))

(defmethod nodelist filter (fun)
  (@ fun _list))

(defmacro def-nodelist-method (name &rest args)
  `(defmethod nodelist ,name ,args
     (@ (i _list)
       ((slot-value i ',name) ,@args))))

(def-nodelist-method remove)
(def-nodelist-method remove-without-event-listeners)
(def-nodelist-method show)
(def-nodelist-method hide)

(finalize-class nodelist)
