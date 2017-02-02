(fn fire-mousemove-event ()
  (alet *event-manager*
    (!.fire (new caroshi-event :new-type "mousemove"
					 	       :new-button (!.last-button-state)
                     	       :x !.x
                     	       :y !.y))))

(fn fire-document-modified-event (elm)
  (*event-manager*.fire-on-element elm (new caroshi-event :new-type "document-modified")))

(fn fire-text-modified-event (elm)
  (*event-manager*.fire-on-element elm (new caroshi-event :new-type "text-modified")))

(fn force-mousemove-event ()
  (do-wait 1
    (fire-mousemove-event)))

(defmacro init-event-module (place debug-name)
  (| (string? debug-name)
	 (error "string expected as debug-name"))
  `(aprog1 (new event-module ,debug-name)
     (& ,place
        ((slot-value ,place 'kill)))
     (= ,place !)
     (*event-manager*.add !)))
