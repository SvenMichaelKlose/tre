;;;;; tré – Copyright (c) 2008,2012 Sven Michael Klose <pixel@copei.de>

(defclass caroshi-element ())

(defmember caroshi-element
	some-member)

(defclass (caroshi-css-layout caroshi-element) ()
  this)

(defmethod caroshi-css-layout some-member-function ())

;(defun ducktype-test ()
;  (let o (new caroshi-element)
;    (o.some-member-function)
;    (= o.some-member 'fnord)
;    o.some-member))

;(ducktype-test)
