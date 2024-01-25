(defclass nodelist (x)
  (= _list x))

(defmember nodelist _list)

(defmethod nodelist list () _list)

(defmethod nodelist map (fun)
  (@ [~> fun _] _list))

(defmacro def-nodelist-method (name &rest args)
  `(defmethod nodelist ,name ,args
     (@ (i _list)
       ((slot-value i ',name) ,@args))))

(def-nodelist-method attr name val)
(def-nodelist-method add-class x)
(def-nodelist-method remove-class x)
(def-nodelist-method remove-classes x)
(def-nodelist-method remove)
(def-nodelist-method show)
(def-nodelist-method hide)
(def-nodelist-method set-style name val)
(def-nodelist-method remove-styles)

(finalize-class nodelist)
