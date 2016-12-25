(defbuiltin make-array (&optional (dimensions 1))
  (cl:make-array dimensions))

(defbuiltin =-aref (v x i)
  (cl:setf (cl:aref x i) v))
