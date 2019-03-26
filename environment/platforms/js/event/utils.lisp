;;;;; tré – Copyright (c) 2008–2011,2013 Sven Michael Klose <pixel@copei.de>

(defun fire-mousemove-event ()
  (alet event-manager
    (!.fire (new caroshi-event :new-type "mousemove"
					 	       :new-button (!.last-button-state)
                     	       :x !.x
                     	       :y !.y))))

(defun fire-element-inserted-event (elm)
  (alet event-manager
    (!.fire-on-element elm (new caroshi-event :new-type "element-inserted"
					 	                      :new-button (!.last-button-state)
                     	                      :x !.x
                     	                      :y !.y))))

(defun fire-document-modified-event (elm)
  (event-manager.fire-on-element elm (new caroshi-event :new-type "document-modified")))

(defun fire-text-modified-event (elm)
  (event-manager.fire-on-element elm (new caroshi-event :new-type "text-modified")))

(defun force-mousemove-event ()
  (wait #'fire-mousemove-event 1))

(defun swallow-event (evt)
  (evt.discard)
  (evt.send-natively nil))

(defmacro init-event-module (place debug-name)
  (| (string? debug-name)
	 (error "string expected as debug-name"))
  `(aprog1 (new event-module ,debug-name)
     (kill+set ,place !)
     (event-manager.add !)))
