(defclass caroshi-event (&key (native-event nil) (new-type nil) (new-button nil) (x nil) (y nil))
  (clr _x _y _stop)
  (= _send-natively? t)
  (!? native-event (_copy-native-event-data !))
  (!? new-type (= type !))
  (!? x (= _x !))
  (!? y (= _y !))
  (!? new-button (= button !))
  this)

(defmember caroshi-event
	_native-event
	type
	_x
	_y
	_element
	button
	char-code
	key-code
	data-transfer
	_stop
	_send-natively?)

(defmethod caroshi-event _copy-native-event-data (evt)
  (= _native-event evt
     type          evt.type
	 _element      (dom-extend evt.target)
	button evt.button)
  (? (eql "keypress" type)
     (= char-code (| evt.which evt.char-code evt.key-code))
	 (= key-code evt.key-code))
  (with (docelm document.document-element
		 body   document.body)
  	(= _x (| evt.page-x
		     (number+ evt.client-x (- (| docelm.scroll-left body.scroll-left)
						              (| docelm.client-left 0)))))
  	(= _y (| evt.page-y
		     (number+ evt.client-y (- (| docelm.scroll-top body.scroll-top)
									     (| docelm.client-top 0))))))
  (when (defined? evt.data-transfer)
	(= data-transfer evt.data-transfer))
  this)

(defmethod caroshi-event mouse-event? ()
  (find type '("mousedown" "mouseup" "mousemove" "mouseover")))

(defmethod caroshi-event left-button? ()   (== 0 button))
(defmethod caroshi-event middle-button? () (== 1 button))
(defmethod caroshi-event right-button? ()  (== 2 button))

(defmethod caroshi-event pointer-x () _x)
(defmethod caroshi-event pointer-y () _y)
(defmethod caroshi-event element ()   _element)

(defmethod caroshi-event set-element (x)
  (= _element x))

(defmethod caroshi-event relative-pointer ()
  (with (x _x
         y _y)
    (iterate e e.offset-parent _element (values x y)
      (= x (- x e.offset-left))
      (= y (- y e.offset-top)))))

(defmethod caroshi-event bubble	()
  (awhen _element
	(unless (| (not (element? !))
               (eql "BODY" !.tag-name))
	  (= _element !.parent-node))))

(defmethod caroshi-event discard ()
  (= _stop t))

;; For the EVENT-MANAGER only.
(defmethod caroshi-event _stop-original ()
  (!? _native-event
      (native-stop-event !)))

(defmethod caroshi-event send-natively (x)
  (= _send-natively? x))

(finalize-class caroshi-event)
