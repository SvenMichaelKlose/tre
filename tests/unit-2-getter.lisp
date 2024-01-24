(defclass record ()
  (= _data {"fnord": t}))

(defmember record _data)

(defmethod record aref? (name)
  (defined? (%aref _data name)))

(defmethod record aref (name)
  (%aref _data name))

(defmethod record =-aref (v name)
  (%=-aref v _data name)
  v)

(defmethod record delete-aref (name)
  (%unset (%aref _data name)))

(finalize-class record)

(| (eq t (%aref (new record) "fnord"))
   (error "Property getter not working."))
