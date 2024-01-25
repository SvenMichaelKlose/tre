(defbuiltin string-concat (&rest x)
  (*> #'CL:CONCATENATE 'CL:STRING x))

(defbuiltin string (x)
  (? (CL:NUMBERP x)
     (CL:FORMAT nil "~A" x)
     (CL:STRING x)))

(defbuiltin string== (a b)
  (CL:STRING= a b))

(defbuiltin list-string (x)
  (| (list? x)
     (error "List expected instead of ~A." x))
  (CL:CONCATENATE 'CL:STRING x))

(defbuiltin %elt-string (obj idx)
  (CL:ELT obj idx))

(defbuiltin char (obj idx)
  (CL:ELT obj idx))
