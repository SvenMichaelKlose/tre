;;;;; tré – Copyright (c) 2008–2010,2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate add-event-listener attach-event)

(declare-cps-exception native-add-event-listener)

(defun native-add-event-listener (elm typ fun)
  (with (f [funcall fun _])
    (?
      elm.add-event-listener (elm.add-event-listener typ f false)
      elm.attach-event       (elm.attach-event (+ "on" typ) f)
      (error "Can't determine function to add the event listener for '~A' on DOM object ~A." typ elm))))

(dont-obfuscate remove-event-listener detach-event)

(defun native-remove-event-listener (elm typ fun)
  (? elm.remove-event-listener
	 (elm.remove-event-listener typ fun false)
	 (elm.detach-event (+ "on" typ) fun)))

(dont-obfuscate prevent-default stop-propagation)

(defun native-stop-event (evt)
  (& evt.prevent-default
     (evt.prevent-default))
  (& evt.stop-propagation
     (evt.stop-propagation)))

(dont-obfuscate create-event-object create-event fire-event init-event dispatch-event)

(defun native-fire-event (elm event-name)
  (? document.create-event-object
     (elm.fire-event (+ "on" event-name) (document.create-event-object))
     (let evt (document.create-event "HTMLEvents")
       (evt.init-event event-name t t)
       (not (elm.dispatch-event evt)))))

(defun native-fire-d-o-m-content-loaded (&optional (html-document document))
  (native-fire-event document "DOMContentLoaded"))
