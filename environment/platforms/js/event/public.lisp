; TODO: Why is this wrapping to NATIVE-*?

(fn caroshi-add-event-listener (typ fun elm)
  (native-add-event-listener elm typ fun))

(fn caroshi-remove-event-listener (typ fun elm)
  (native-remove-event-listener elm typ fun))

(fn caroshi-stop-event (evt)
  (native-stop-event evt))
