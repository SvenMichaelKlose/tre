(defbuiltin make-hash-table (&key (test #'eql))
  (CL:MAKE-HASH-TABLE :TEST (?
                              (CL:EQ test #'eq)        #'CL:EQ
                              (| (CL:EQ test #'eql)
                                 (CL:EQ test #'==))    #'CL:EQL
                              (CL:EQ test #'string==)  #'CL:EQUAL
                              test)))

(defbuiltin hash-table? (x)  (CL:HASH-TABLE-P x))
(defbuiltin href (x i)       (CL:GETHASH i x))
(defbuiltin =-href (v x i)   (CL:SETF (CL:gethash i x) v))
(defbuiltin hremove (x k)    (CL:REMHASH k x))

(defbuiltin copy-hash-table (x)
  (aprog1 (CL:MAKE-HASH-TABLE :TEST (CL:HASH-TABLE-TEST x)
                              :SIZE (CL:HASH-TABLE-SIZE x))
    (CL:MAPHASH #'((k v)
                    (CL:SETF (CL:GETHASH k !) v))
                x)))

(defbuiltin hashkeys (x)
  (aprog1 nil
    (CL:MAPHASH (lambda (k v)
                  v
                  (CL:PUSH k !))
             x)))
