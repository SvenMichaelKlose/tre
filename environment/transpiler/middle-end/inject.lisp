;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defvar *former-position* nil)

(defun foureign-cpr? (x old)
  (& (cons? x)
     (| (& (not (eq old (cpr x)))
           (cpr x))
        (foureign-cpr? x. old)
        (foureign-cpr? .x old))))

(metacode-walker inject-debugging (x)
	:if-cons (!? (foureign-cpr? x *former-position*)
                 (progn
                   (= *former-position* !)
                   `((%setq nil (%debug-step ,(car !) ,(car .!) ,(cdr .!)))
                     ,x.))
                 (list x.)))
