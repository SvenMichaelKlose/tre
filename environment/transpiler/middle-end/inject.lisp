;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defvar *former-position* nil)

(def-head-predicate debugger-step)

(defun same-location? (a b)
  (& a b
     (string== a. b.)
     (== (car .a) (car .b))
     (== (cdr .a) (cdr .b))))

(defun find-next-location (x old)
  (& (cons? x)
     (| (& (not (same-location? old (cpr x)))
           (cpr x))
        (find-next-location x. old)
        (find-next-location .x old))))

(metacode-walker inject-debugging (x)
	:if-cons (!? (& (%setq? x.)
                    (not (debugger-step? (%setq-value x.)))
                    (find-next-location x *former-position*))
                 (progn
                   (= *former-position* !)
                   `((%setq nil (debugger-step ,(car !) ,(car .!) ,(cdr .!)))
                     ,x.))
                 (list x.)))
