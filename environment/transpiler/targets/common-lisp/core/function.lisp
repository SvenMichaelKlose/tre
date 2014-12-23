; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defvar *functions* nil)
(defvar *function-atom-sources* (make-hash-table :test #'eq))

(push '*functions* *universe*)

(defbuiltin function-native (x) x)

(defbuiltin function-source (x)
  (| (cl:functionp x)
     (cl:error "Not a function."))
  (cl:gethash x *function-atom-sources*))

(defbuiltin =-function-source (v x)
  (cl:setf (cl:gethash x *function-atom-sources*) v))

(defbuiltin function-bytecode (x) x nil)
