; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@copei.de>

(defvar *functions* nil)

(defbuiltin function-native (x) x)

(defbuiltin function-source (x)
  (| (cl:functionp x)
     (cl:error "Not a function."))
  (cl:gethash x *functions*))

(defbuiltin =-function-source (v x)
  (cl:setf (cl:gethash x *functions*) v))

(defbuiltin function-bytecode (x) x nil)
