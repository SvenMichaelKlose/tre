;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defclass nodelist (x)
  (= _list x)
  this)

(defmember nodelist _list)

(defmethod nodelist list () _list)

(defmacro def-nodelist-method (name &rest args)
  `(defmethod nodelist ,name ,args
     (dolist (i _list)
       ((slot-value i ',name) ,@args))))

(def-nodelist-method remove)
(def-nodelist-method show)
(def-nodelist-method hide)

(finalize-class nodelist)
