;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(define-js-macro userfun_cons (x y)
  `("new " ,(compiled-function-name '%cons) "(" ,x "," ,y ")"))

(mapcan-macro p
	'((userfun_car _)
	  (userfun_cdr __))
  `((define-js-macro ,p. (x)
      `(%%native ,,(js-nil? x) " ? null : " ,,x "." ,.p.))
    (define-js-macro ,.p. (v x)
      `(%%native ,,x "." ,.p. " = " ,,v))))
