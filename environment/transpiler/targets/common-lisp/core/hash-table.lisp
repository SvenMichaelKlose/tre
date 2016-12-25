(defbuiltin make-hash-table (&key (test #'eql))
  (cl:make-hash-table :test (?
                              (cl:eq test #'eq)        #'cl:eq
                              (| (cl:eq test #'eql)
                                 (cl:eq test #'==))    #'cl:eql
                              (cl:eq test #'string==)  #'cl:equal
                              test)))

(defbuiltin hash-table? (x)  (cl:hash-table-p x))
(defbuiltin href (x i)       (cl:gethash i x))
(defbuiltin =-href (v x i)   (cl:setf (cl:gethash i x) v))
(defbuiltin hremove (x k)    (cl:remhash k x))

(defbuiltin copy-hash-table (x)
  (aprog1 (cl:make-hash-table :test (cl:hash-table-test x)
                              :size (cl:hash-table-size x))
    (cl:maphash #'((k v)
                    (cl:setf (cl:gethash k !) v))
                x)))

(defbuiltin hashkeys (x)
  (aprog1 nil
    (cl:maphash (lambda (k v)
                  v
                  (cl:push k !))
             x)))
