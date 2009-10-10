;;;;; Caroshi ECMAScript library
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Elements

(defclass caroshi-element ())

(defmember caroshi-element
	some-member)

(defmethod caroshi-element some-member-function ())

;(defun ducktype-test ()
;  (let o (new caroshi-element)
;    (o.some-member-function)
;    (setf o.some-member 'fnord)
;    o.some-member))

;(ducktype-test)
