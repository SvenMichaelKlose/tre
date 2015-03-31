;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defvar *stopping-point?* nil)

(defun set-stopping-point (fun)
  (= *stopping-point?* nil))

(defun pause-program? (id)
  (funcall *stopping-point?* id))

(defun %debug-step (continuer id)
  (? (pause-program? id)
     (debugger continuer id)
     (%cps-step continuer)))

(defun debug-step (id)
  (set-stopping-point #'identity)
  (continue-program))

(defun debug-next (id)
  (alet *backtrace*
    (set-stopping-point [eq ! *backtrace*]))
  (continue-program))

(defun debug-leave (id)
  (alet .*backtrace*
    (set-stopping-point [eq ! *backtrace*]))
  (continue-program))
