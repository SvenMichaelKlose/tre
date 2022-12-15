; DO NOT USE THESE!
; TODO: Remove all of these since Internet Explorer is gone. (Yes!)

(fn native-add-event-listener (elm typ fun)
  (elm.add-event-listener typ [funcall fun _] false))

(fn native-remove-event-listener (elm typ fun)
   (elm.remove-event-listener typ fun false))

(fn native-stop-event (evt)
  (evt.prevent-default)
  (evt.stop-propagation))

(fn native-fire-event (elm event-name)
  (!= (document.create-event "HTMLEvents")
    (!.init-event event-name t t)
    (elm.dispatch-event !)))

(fn native-fire-d-o-m-content-loaded (&optional (html-document document))
  (native-fire-event document "DOMContentLoaded"))
