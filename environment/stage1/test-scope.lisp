;;;;; tré – Copyright (c) 2009–2010,2012,2014 Sven Michael Klose <pixel@hugbox.org>

(define-test "can handle nested functions with double argument names"
  ((let x 'y
	 (let x 'z
       x
	   nil)
	 x))
  'y)

(define-test "can handle nested functions with double argument names"
  ((== 3
	  (let x 1
	    (let y 2
		   (+ x y)))))
  t)

(define-test "can handle closures"
  ((equal '(1 2 3)
		  (let n 1
	  	    (mapcar [+ _ n]
				    '(0 1 2)))))
  t)
