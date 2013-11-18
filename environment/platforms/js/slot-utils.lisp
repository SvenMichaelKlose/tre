;;;;; tré – Copyright (c) 2008–2009,2012 Sven Michael Klose <pixel@copei.de>

(defmacro call-slot (place method &rest args)
  `((slot-value ,place ,(list 'quote method)) ,@args))

(defmacro call-slot-when (place method &rest args )
  `(when ,place
	 (call-slot ,place ,method ,@args)))

(defmacro exec+set (place op value)
  `(progn
     (when ,place
	   (call-slot ,place ,op))
     (= ,place ,value)))

(defmacro exec+clear (place op)
  `(exec+set ,place ,op nil))

(mapcar-macro x
	'(close kill remove)
  `(defmacro ,($ x '+clear) (place)
     `(exec+clear ,,place ,x)))

(defmacro kill+set (place value)
  `(exec+set ,place kill ,value))

(defmacro remove+set (place value)
  `(exec+set ,place remove ,value))

(defmacro defmethod-when (cls name args predicate &rest body)
  `(defmethod ,cls ,name ,args
	 (when ,predicate
	   ,@body)))
