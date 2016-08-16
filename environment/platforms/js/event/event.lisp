; tré – Copyright (c) 2008–2013,2016 Sven Michael Klose <pixel@copei.de>

(defclass caroshi-event (&key (native-event nil) (new-type nil) (new-button nil) (x nil) (y nil))
  (clr _x _y
	   _stop-bubbling
	   _stop)
  (= _send-natively? t)
  (!? native-event (_copy-native-event-data !))
  (!? new-type (= type !))
  (!? x (= _x !))
  (!? y (= _y !))
  (!? new-button (= button !))
  this)

(dont-obfuscate
	type
	button
	char-code
	key-code
    which
	target
	data-transfer
	files
	get-as-binary
	get-as-data-u-r-l
	get-as-text
    offset-parent
    offset-top
    offset-left)

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
	_stop-bubbling
	_stop
	_send-natively?)

(dont-obfuscate
	scroll-left
	scroll-top
	client-left
	client-top
	client-x
	client-y
	page-x
	page-y)
	
(defmethod caroshi-event _copy-native-event-data (evt)
  (= _native-event evt
     type          evt.type
	 _element      (dom-extend evt.target)
	button evt.button)
  (? (== "keypress" type)
     (= char-code (| evt.which evt.char-code evt.key-code))
	 (= key-code evt.key-code))
  (with (docelm document.document-element
		 body   document.body)
  	(= _x (| evt.page-x
		     (integer+ evt.client-x (integer- (| docelm.scroll-left body.scroll-left)
							                  (| docelm.client-left 0)))))
  	(= _y (| evt.page-y
		     (integer+ evt.client-y (integer- (| docelm.scroll-top body.scroll-top)
									          (| docelm.client-top 0))))))
  (when (defined? evt.data-transfer)
	(= data-transfer evt.data-transfer))
  this)

(defmethod caroshi-event mouse-event? ()
  (in=? type "mousedown" "mouseup" "mousemove" "mouseover"))

(defmethod caroshi-event left-button? ()   (integer== 0 button))
(defmethod caroshi-event middle-button? () (integer== 1 button))
(defmethod caroshi-event right-button? ()  (integer== 2 button))

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
               (== "BODY" !.tag-name))
	  (= _element !.parent-node))))

(defmethod caroshi-event stop-bubbling ()
  (= _stop-bubbling t))

(defmethod caroshi-event stop ()
  (= _stop t))

(defmethod caroshi-event discard (send-natively?)
  (send-natively send-natively?)
  (stop)
  (stop-bubbling))

;; For the EVENT-MANAGER only.
(defmethod caroshi-event _stop-original ()
  (!? _native-event
      (native-stop-event !)))

(defmethod caroshi-event _reset-flags ()
  (clr _stop-bubbling _stop))

(defmethod caroshi-event send-natively (x)
  (= _send-natively? x))

(finalize-class caroshi-event)
