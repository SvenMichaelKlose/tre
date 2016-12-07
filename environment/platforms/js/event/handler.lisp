; tré – Copyright (c) 2008–2010,2012,2016 Sven Michael Klose <pixel@copei.de>

(defclass _event-handler (elm typ cb)
  (= element elm
     type typ
     callback cb)
  this)

(defmember _event-handler
	element
	type
	callback)

(defmethod _event-handler has-element (x)
  (eq element x))

(defmethod _event-handler has-type (x)
  (eql type x))

(defmethod _event-handler has-callback (x)
  (eq callback x))

(finalize-class _event-handler)
