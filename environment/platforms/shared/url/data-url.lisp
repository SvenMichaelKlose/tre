(defun data-url (x &key typ fmt (encoding nil))
  (+ "data:" typ "/" fmt
     (!? encoding
         (+ ";" encoding)
         "")
     "," x))
