; tré – Copyright (c) 2011–2012,2016 Sven Michael Klose <pixel@copei.de>

(defun data-url (x &key typ fmt (encoding nil))
  (+ "data:" typ "/" fmt
     (!? encoding
         (+ ";" encoding)
         "")
     "," x))
