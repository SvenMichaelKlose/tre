;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defvar *log-events?* nil)

(defun start-debugger ()
  (open-debugger-window)
  (lml2dom *debugger-window*.document.body
           (make-scope (make-funinfo :args '(a1 a2) :vars '(x y)))))

(start-debugger)
