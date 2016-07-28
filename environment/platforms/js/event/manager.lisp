; tré – Copyright (c) 2008–2016 Sven Michael Klose <pixel@hugbox.org>

(defun bind-event-listener (obj fun)
  (assert (function? fun) "BIND-EVENT-LISTENER requires a function")
  [applymethod obj fun (new caroshi-event :native-event _)])

(defclass _event-manager ()
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

(defmember _event-manager
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

(defmethod _event-manager set-send-natively-by-default? (doc x)
  (| (document? doc)
     (error "Document node expected instead of ~A." doc))
  (= doc._send-natively? x))

(defmethod _event-manager shift-down? () (get-key-stat 16))
(defmethod _event-manager ctrl-down? ()  (get-key-stat 17))
(defmethod _event-manager alt-down? ()   (get-key-stat 18))

(defmethod _event-manager button-down? ()            _button-down?)
(defmethod _event-manager last-button-state ()      _last-button-state)
(defmethod _event-manager last-click-shift-down? () _last-click-shift-down?)

(defmethod _event-manager get-key-stat (code)
  (unless (undefined? (aref _key-stats code))
    (aref _key-stats code)))

(defmethod _event-manager reset-pointer-info ()
  (= this.x 0
	 this.y 0)
  (clr element))

(defmethod _event-manager dragging? ()       _dragging?)
(defmethod _event-manager dragstart-x ()     _dragstart-x)
(defmethod _event-manager dragstart-y ()     _dragstart-y)
(defmethod _event-manager dragged-element () _dragged-element)

(defmethod _event-manager add (module)
  (push module _modules)
  module)

(defmethod _event-manager kill (module)
  (assert (not module._killed?) (+ "module '" module._name "' already killed"))
  (= module._killed? t)
  (= _modules (remove module _modules :test #'eq))
  nil)

(defmethod _event-manager unhook (obj)
  (when (eq element obj)
    (clr element))
  (adolist _modules
	(!.unhook obj)))

(defmethod _event-manager fire-on-element (elm evt)
  (= evt._element elm)
  (_generic-handler evt))

(defmethod _event-manager fire (evt)
  (fire-on-element (document.body.find-element-at (evt.pointer-x) (evt.pointer-y)) evt))

;;;; NATIVE ELEMENT HANDLING

(defmethod _event-manager _dochook (doc typ fun)
  (? (cons? typ)
     (adolist typ
       (_dochook doc ! fun))
     (push (. typ (native-add-event-listener doc typ fun))
           (href _original-listeners doc))))

(defmethod _event-manager _non-generic-event (x)
  (? (string? x) (| (member x *non-generic-events* :test #'string==)
                    (alert (+ "'" x "' is a generic event.")))
     (cons? x)   (adolist x
                   (_non-generic-event !))
     (error "Event name string expected instead of ~A." x))
  x)

(defmethod _event-manager init-document (doc)
  (set-send-natively-by-default? doc nil)
  (let exclusions `("mouseup" "mousedown" ,@(copy-list *ignored-dragndrop-events*) "drop" ,@(copy-list *key-events*) "unload")
    (_dochook doc (remove-if [member _ exclusions :test #'string==] *all-events*)
              (bind-event-listener this this._generic-handler)))

  (_dochook doc (_non-generic-event "mouseup")    (bind-event-listener this this._mouseup))
  (_dochook doc (_non-generic-event "mousedown")  (bind-event-listener this this._mousedown))
  (_dochook doc (_non-generic-event "drop")       (bind-event-listener this this._externaldrop))
  (_dochook doc (_non-generic-event *key-events*) (bind-event-listener this this._generic-keyhandler))
  (_dochook doc *ignored-dragndrop-events* #'native-stop-event)
  (native-add-event-listener doc "unload" #'((evt)
								               (_generic-handler evt)
							                   (_remove-event-listeners doc))))

(defmethod _event-manager _externaldrop (evt)
  (evt._stop-original)
  (_dispatch "externaldrop" evt))

(defmethod _event-manager _remove-event-listeners (doc)
  (adolist ((href _original-listeners doc))
	(native-remove-event-listener document !. .!)))

(defmethod _event-manager _sensible-position? (x y)
  (& x y
  	 (not (& (zero? x) (zero? y)))))

;;;; EVENT UTILITIES

(defmethod _event-manager _add-moved-distance-to-event (evt)
  (= evt.distance-x (- (evt.pointer-x) this.x)
     evt.distance-y (- (evt.pointer-y) this.y)))

(defmethod _event-manager _update-global-data (evt)
  (= element (evt.element))
  (when (evt.mouse-event?)
    (with (x (evt.pointer-x)
		   y (evt.pointer-y))
	  (when (_sensible-position? x y)
	    (_add-moved-distance-to-event evt)
        (= this.x x
              this.y y)))))

;;;; EVENT DISPATCH

(defmethod _event-manager _find-handlers-of-element (handlers elm)
  (remove-if-not [_.has-element elm] handlers))

(defmethod _event-manager _find-handlers-of-type (handlers type)
  (remove-if-not [_.has-type type] handlers))
      
(defmethod _event-manager _call-handlers (evt module handlers)
  (adolist handlers
	(log-events "Calling handler for ~A event/module `~A'.~%" evt.type (module.get-name))
    (!.callback evt this)
	(!? evt._stop
        (return !))))

(defmethod _event-manager _find-handlers (evt module elm)
  (_find-handlers-of-element (_find-handlers-of-type module._handlers evt.type) elm))

(defmethod _event-manager _handle-modules (evt elm modules stopped-modules)
  (adolist modules
	(evt._reset-flags)
    (unless (| !._killed? (member ! (queue-list stopped-modules) :test #'eq))
      (_call-handlers evt ! (_find-handlers evt ! elm))
      (!? evt._stop
          (return !))
	  (when evt._stop-bubbling
		(enqueue stopped-modules !)))))

(defmethod _event-manager _bubble (evt init-elm)
  (with (modules         (copy-list _modules)
		 stopped-modules (make-queue))
    (when (evt.element)
	  (loop
        (when (evt.element)._hooked?
          (_handle-modules evt (evt.element) modules stopped-modules))
        (!? (| evt._stop
               (not (evt.bubble)))
            (return !)))
      (unless evt._stop
        (= evt._element init-elm)
        (_handle-modules evt nil modules stopped-modules)))))

(defmethod _event-manager _dispatch (type evt)
  (log-events "Dispatching ~A event on ~A, X: ~A, Y: ~A.~%"
              type (!? (evt.element) !.tag-name) (evt.pointer-x) (evt.pointer-y))
  (let e (copy-hash-table evt)
    (= e.type type)
    (_bubble e (evt.element))
    (| e._send-natively?
       (e._stop-original))
    ,(when *log-events?*
       `(format t "~A event ~A sent natively.~%" type (? evt._send-natively? "" "NOT "))))
  t)

;;;; DRAG'N DROP EVENT GENERATION

(defmethod _event-manager _dnd-init ()
  (= _threshold 4
     _dragstart-x 0
     _dragstart-y 0)
  (clr _dragged-element
	   _dragging?))

(defmethod _event-manager _dnd-update-position (evt)
  (= _dragstart-x (evt.pointer-x)
     _dragstart-y (evt.pointer-y)))

(defmethod _event-manager _dnd-mousedown (evt)
  (= _button-down? t)
  (unless _dragging?
    (_dnd-update-position evt)
    (= _dragged-element (evt.element))))

(defmethod _event-manager _dnd-start (evt)
  (= _dragging? t)
  (evt.set-element _dragged-element)
  (_dispatch "caroshidragstart" evt))

(defmethod _event-manager _dnd-past-threshold? (evt)
  (< (distance (evt.pointer-x) (evt.pointer-y) _dragstart-x _dragstart-y)
     _threshold))

(defmethod _event-manager _dnd-mousemove (evt)
  (?
    (not _dragged-element) nil
    _dragging? (_dispatch "caroshidrag" evt)
    (_dnd-past-threshold? evt) nil
    (_dnd-start evt)))

;; Drop element if it can be catched and end drag mode.
(defmethod _event-manager _dnd-mouseup (evt)
  (clr _button-down?)
  (when _dragging?
	(_dispatch "caroshidrop" evt))
  (clr _dragging?
	   _dragged-element))

;;;; EVENT HANDLERS

(dont-obfuscate get-selection range-count get-range-at collapsed)

(defmethod _event-manager _handle-selection (evt)
  (let has-selection?  (let s (window.get-selection)
	      				 (& (< 0 s.range-count)
			                (let r (s.get-range-at 0)
						      (not r.collapsed))))
    (unless (eq _has-selection? has-selection?)
	  (_dispatch "selectionchange" evt))
    (= _has-selection? has-selection?)))

;; Generic event handler.
(defmethod _event-manager _generic-handler (evt)
  (_update-global-data evt)
  (& (== "mousemove" evt.type)
	 (& (== 0 evt.button)
        (_dnd-mousemove evt))
     (_handle-selection evt))
  (unless (& (== "click" evt.type)
		     (not (== 0 evt.button)))
    (_dispatch evt.type evt))
  t)

(defmethod _event-manager _save-key-stat-down (code)
  (= (aref _key-stats code) t))

(defmethod _event-manager _save-key-stat-up (code)
  (clr (aref _key-stats code)))

(defmethod _event-manager _save-key-stat (evt)
  (?
	(== evt.type "keydown") (_save-key-stat-down evt.key-code)
	(== evt.type "keyup")   (_save-key-stat-up evt.key-code)))

(defmethod _event-manager _generic-keyhandler (evt)
  (_save-key-stat evt)
  (_dispatch evt.type evt))

;;;; MOUSE BUTTON EVENTS

;; Event handler for mouseup and mousedown events.
;;
;; This will introduce mouse(left|middle|right)(up|down) events.
(defmethod _event-manager _mousebutton (evt direction)
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

(defmethod _event-manager _mousedown (evt)
  (= _last-click-shift-down? (shift-down?))
  (when (== 0 evt.button)
	(_dnd-mousedown evt))
  (_mousebutton evt "down"))

(defmethod _event-manager _mouseup (evt)
  (when (== 0 evt.button)
	(_dnd-mouseup evt))
  (_mousebutton evt "up"))

(finalize-class _event-manager)

(defvar event-manager (new _event-manager))
(defvar *default-event-module* (aprog1 (new event-module "default")
                                 (event-manager.add !)))
(defvar *event-module* *default-event-module*)
