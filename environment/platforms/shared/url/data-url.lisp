;;;;; tré – Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

(defun data-url (x typ fmt &key (encoding nil))
  (+ "data:" typ "/" fmt
     (!? encoding
         (+ ";" encoding)
         "")
     "," x))
