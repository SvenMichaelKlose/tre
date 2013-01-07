;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defvar *former-position* nil)

(metacode-walker inject-debugging (x)
	:if-cons (? (| (not (cpr x))
                   (eq *former-position* (cpr x)))
                (list x.)
                (progn
                  (= *former-position* (cpr x))
                  `((%setq nil (%debug-step ,(car (cpr x)) ,(cdr (cpr x))))
                    ,x.))))
