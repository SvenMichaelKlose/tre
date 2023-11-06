(defbuiltin make-array (&optional (dimensions 1))
  (CL:MAKE-ARRAY dimensions))

(defbuiltin =-aref (v x i)
  (CL:SETF (CL:AREF x i) v))
