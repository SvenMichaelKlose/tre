(defun bind-event-listener (obj fun)
  (assert (function? fun) "BIND-EVENT-LISTENER requires a function")
  [applymethod obj fun (new caroshi-event :native-event _)])

(defclass event-manager ()
  (clr _modules
       _original-listeners
       _running?
	   _has-selection?
       _button-down?)
  (= _key-stats (make-array))
  (= _original-listeners (make-hash-table))

  (reset-pointer-info)
  (_dnd-init)
  (init-document document)

  this)

(defmember event-manager
	; x y -> use THIS manually
	element
	_modules
	_running?
	_threshold
	_dragstart-x
	_dragstart-y
	_dragged-element
	_dragging?
	_original-listeners
	_last-button-state
	_last-click-shift-down?
	_key-stats
	_running?
	_has-selection?
    _button-down?)

;;;; PUBLIC

(defmethod event-manager set-send-natively-by-default? (doc x)
  (| (document? doc)
     (error "Document node expected instead of ~A." doc))
  (= doc._send-natively? x))

(defmethod event-manager shift-down? () (get-key-stat 16))
(defmethod event-manager ctrl-down? ()  (get-key-stat 17))
(defmethod event-manager alt-down? ()   (get-key-stat 18))

(defmethod event-manager button-down? ()           _button-down?)
(defmethod event-manager last-button-state ()      _last-button-state)
(defmethod event-manager last-click-shift-down? () _last-click-shift-down?)

(defmethod event-manager get-key-stat (code)
  (unless (undefined? (aref _key-stats code))
    (aref _key-stats code)))

(defmethod event-manager reset-pointer-info ()
  (= this.x 0
	 this.y 0)
  (clr element))

(defmethod event-manager dragging? ()       _dragging?)
(defmethod event-manager dragstart-x ()     _dragstart-x)
(defmethod event-manager dragstart-y ()     _dragstart-y)
(defmethod event-manager dragged-element () _dragged-element)

(defmethod event-manager add (module)
  (push module _modules)
  module)

(defmethod event-manager kill (module)
  (assert (not module._killed?) (+ "module '" module._name "' already killed"))
  (= module._killed? t)
  (= _modules (remove module _modules :test #'eq))
  nil)

(defmethod event-manager unhook (obj)
  (& (eq element obj)
     (clr element))
  (@ (i _modules)
	(i.unhook obj)))

(defmethod event-manager fire-on-element (elm evt)
  (= evt._element elm)
  (_generic-handler evt))

(defmethod event-manager fire (evt)
  (fire-on-element (document.body.find-element-at (evt.pointer-x) (evt.pointer-y)) evt))

;;;; NATIVE ELEMENT HANDLING

(defmethod event-manager _dochook (doc typ fun)
  (? (cons? typ)
     (@ (i typ)
       (_dochook doc i fun))
     (acons! typ (native-add-event-listener doc typ fun)
             (href _original-listeners doc))))

(defmethod event-manager _non-generic-event (x)
  (? (string? x) (| (member x *non-generic-events* :test #'string==)
                    (alert (+ "'" x "' is a generic event.")))
     (cons? x)   (@ (i x)
                   (_non-generic-event i))
     (error "Event name string expected instead of ~A." x))
  x)

(defmethod event-manager init-document (doc)
  (set-send-natively-by-default? doc t)
  (let exclusions `("mouseup" "mousedown" ,@(copy-list *ignored-dragndrop-events*) "drop" ,@(copy-list *key-events*) "unload")
    (_dochook doc (remove-if [member _ exclusions :test #'string==] *all-events*)
              (bind-event-listener this this._generic-handler)))

  (_dochook doc (_non-generic-event "mouseup")     (bind-event-listener this this._mouseup))
  (_dochook doc (_non-generic-event "mousedown")   (bind-event-listener this this._mousedown))
  (_dochook doc (_non-generic-event "drop")        (bind-event-listener this this._externaldrop))
  (_dochook doc (_non-generic-event *key-events*)  (bind-event-listener this this._generic-keyhandler))
  (_dochook doc *form-events* (bind-event-listener this this._generic-keyhandler))
  (_dochook doc *ignored-dragndrop-events* #'native-stop-event)
  (native-add-event-listener doc "unload" [(_generic-handler _)
							               (_remove-event-listeners doc)]))

(defmethod event-manager _externaldrop (evt)
  (evt._stop-original)
  (_dispatch "externaldrop" evt))

(defmethod event-manager _remove-event-listeners (doc)
  (@ (i (href _original-listeners doc))
	(native-remove-event-listener document i. .i)))

(defmethod event-manager _sensible-position? (x y)
  (& x y
  	 (not (& (zero? x) (zero? y)))))

;;;; EVENT UTILITIES

(defmethod event-manager _add-moved-distance-to-event (evt)
  (= evt.distance-x (- (evt.pointer-x) this.x)
     evt.distance-y (- (evt.pointer-y) this.y)))

(defmethod event-manager _update-global-data (evt)
  (= element (evt.element))
  (when (evt.mouse-event?)
    (with (x  (evt.pointer-x)
		   y  (evt.pointer-y))
	  (when (_sensible-position? x y)
	    (_add-moved-distance-to-event evt)
        (= this.x x
           this.y y)))))

;;;; EVENT DISPATCH

(defmethod event-manager _find-handlers-of-element (handlers elm)
  (remove-if-not [_.has-element elm] handlers))

(defmethod event-manager _find-handlers-of-type (handlers type)
  (remove-if-not [_.has-type type] handlers))
      
(defmethod event-manager _call-handlers (evt module handlers)
  (@ (i handlers)
	(log-events "Calling handler for ~A event/module `~A'.~%" evt.type (module.get-name))
    (i.callback evt this)
	(when evt._stop
      (log-events "Event stopped.~%")
      (return))))

(defmethod event-manager _find-handlers (evt module elm)
  (_find-handlers-of-element (_find-handlers-of-type module._handlers evt.type) elm))

(defmethod event-manager _handle-modules (evt elm modules)
  (@ (i modules)
    (log-events "Searching event handler in module '~A' / ~A on ~A (has ~A).~%"
                (i.get-name) (!? evt !.type) (!? elm !.tag-name)
                (concat-stringtree (pad (@ [+ _.type "/" (!? _.element !.tag-name)] i._handlers) " ")))
    (unless i._killed?
      (_call-handlers evt i (_find-handlers evt i elm))
      (& evt._stop
         (return)))))

(defmethod event-manager _bubble (evt init-elm)
  (let modules (copy-list _modules)
    (when (evt.element)
	  (loop
        (& (evt.element)._hooked?
           (_handle-modules evt (evt.element) modules))
        (& (| evt._stop
              (not (evt.bubble)))
            (return)))
      (unless evt._stop
        (= evt._element init-elm)
        (_handle-modules evt nil modules)))))

(defmethod event-manager _dispatch (type evt)
  (log-events "Dispatching ~A event on ~A, X: ~A, Y: ~A.~%"
              type (!? (evt.element) !.tag-name) (evt.pointer-x) (evt.pointer-y))
  (let e (copy-hash-table evt)
    (= e.type type)
    (_bubble e (evt.element))
    (| e._send-natively?
       (e._stop-original))
    ,(& *log-events?*
        `(format t "~A event ~Asent natively.~%" type (? evt._send-natively? "" "NOT "))))
  t)

;;;; DRAG'N DROP EVENT GENERATION

(defmethod event-manager _dnd-init ()
  (= _threshold 4
     _dragstart-x 0
     _dragstart-y 0)
  (clr _dragged-element
	   _dragging?))

(defmethod event-manager _dnd-update-position (evt)
  (= _dragstart-x (evt.pointer-x)
     _dragstart-y (evt.pointer-y)))

(defmethod event-manager _dnd-mousedown (evt)
  (= _button-down? t)
  (unless _dragging?
    (_dnd-update-position evt)
    (= _dragged-element (evt.element))))

(defmethod event-manager _dnd-start (evt)
  (= _dragging? t)
  (evt.set-element _dragged-element)
  (_dispatch "caroshidragstart" evt))

(defmethod event-manager _dnd-past-threshold? (evt)
  (< (distance (evt.pointer-x) (evt.pointer-y) _dragstart-x _dragstart-y)
     _threshold))

(defmethod event-manager _dnd-mousemove (evt)
  (?
    (not _dragged-element)     nil
    _dragging?                 (_dispatch "caroshidrag" evt)
    (_dnd-past-threshold? evt) nil
    (_dnd-start evt)))

;; Drop element if it can be catched and end drag mode.
(defmethod event-manager _dnd-mouseup (evt)
  (clr _button-down?)
  (& _dragging?
	 (_dispatch "caroshidrop" evt))
  (clr _dragging?
	   _dragged-element))

;;;; EVENT HANDLERS

(defmethod event-manager _handle-selection (evt)
  (let has-selection?  (let s (window.get-selection)
	      				 (& (< 0 s.range-count)
			                (let r (s.get-range-at 0)
						      (not r.collapsed))))
    (| (eq _has-selection? has-selection?)
	   (_dispatch "selectionchange" evt))
    (= _has-selection? has-selection?)))

;; Generic event handler.
(defmethod event-manager _generic-handler (evt)
  (_update-global-data evt)
  (& (eql "mousemove" evt.type)
	 (& (eql 0 evt.button)
        (_dnd-mousemove evt))
     (_handle-selection evt))
  (| (& (eql "click" evt.type)
        (not (== 0 evt.button)))
    (_dispatch evt.type evt))
  t)

(defmethod event-manager _generic-keyhandler (evt)
  (= (aref _key-stats evt.key-code) (eql evt.type "keydown"))
  (_dispatch evt.type evt))

;;;; MOUSE BUTTON EVENTS

;; Event handler for mouseup and mousedown events.
;;
;; This will introduce mouse(left|middle|right)(up|down) events.
(defmethod event-manager _mousebutton (evt direction)
  (_dispatch (+ "mouse"
				direction
	       		(case evt.button
	       		  0 "left"
	       		  1 "middle"
	       		  2 "right"))
			 evt)
  (_dispatch (+ "mouse" direction) evt)
  (= _last-button-state evt.button)
  t)

(defmethod event-manager _mousedown (evt)
  (= _last-click-shift-down? (shift-down?))
  (& (zero? evt.button)
	 (_dnd-mousedown evt))
  (_mousebutton evt "down"))

(defmethod event-manager _mouseup (evt)
  (& (zero? evt.button)
	 (_dnd-mouseup evt))
  (_mousebutton evt "up"))

(finalize-class event-manager)

(defvar *event-manager* (new event-manager))
(defvar *event-module* (new event-module "default"))
(*event-manager*.add *event-module*)
