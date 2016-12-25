(defvar *previous-position* nil)

(def-head-predicate debugger-step)

(defun same-or-previous-location? (a b)
  (& a b
     (string== a. b.)
     (| (> (cdr .a) (cdr .b))
        (? (== (cdr .a) (cdr .b))
           (>= (car .a) (car .b))))))

(defun find-next-location (x old)
  (& (cons? x)
     (| (& (not (same-or-previous-location? old (cpr x)))
           (let section (current-section)
             (alet (cpr x)
               (& (string? section)
                  (string== section !.)
                  !))))
        (find-next-location x. old)
        (find-next-location .x old))))

(metacode-walker inject-debugging (x)
	:if-cons (!? (& (%=? x.)
                    (find-next-location x *previous-position*))
                 {(= *previous-position* !)
                  `((%= nil (debugger-step ,(car !) ,(car .!) ,(cdr .!)))
                    ,x.)}
                 (list x.)))
