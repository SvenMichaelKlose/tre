;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(define-js-macro userfun_cons (x y)
  `("new " ,(compiled-function-name *transpiler* '%cons) "(" ,x "," ,y ")"))

(mapcan-macro p
	'((userfun_car _)
	  (userfun_cdr __))
  (unless *assert*
    `((define-js-macro ,p. (x)
        `(%transpiler-native ,,(js-nil? x) " ? null : " ,,x "." ,.p.))
      (define-js-macro ,.p. (v x)
        `(%transpiler-native ,,x "." ,.p. " = " ,,v)))))
