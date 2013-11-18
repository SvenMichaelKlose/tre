;;;;; tré – Copyright (c) 2011 Sven Michael Klose <pixel@copei.de>

(defun caroshi-add-event-listener (typ fun elm)
  (native-add-event-listener elm typ fun))

(defun caroshi-remove-event-listener (typ fun elm)
  (native-remove-event-listener elm typ fun))

(defun caroshi-stop-event (evt)
  (native-stop-event evt))
