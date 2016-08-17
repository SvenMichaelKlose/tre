; tré – Copyright (c) 2008–2014,2016 Sven Michael Klose <pixel@copei.de>

(defclass event-module (name)
  (log-events "New event module `~A'.~%" name)
  (= _name     name
	 _handlers nil
	 _killed?  nil)
  this)

(defmember event-module
	_name
	_handlers
	_killed?)

(defmethod event-module get-name ()      _name)
(defmethod event-module set-name (name)  (= _name name))
(defmethod event-module handlers ()      _handlers)

(defmethod event-module _hook-type (type callback-fun elm)
  (with (slf      this
         handler  (new _event-handler (? (undefined? elm) nil elm) type callback-fun))
    (push handler _handlers)
    (when elm
      (push #'(()
                 (= _handlers (remove-if [_.has-element elm] _handlers)))
            elm._unhooks))))

(defmethod event-module hook (types callback-fun elm)
  (assert (function? callback-fun) "callback is not a function")
  (when elm
	(= elm._hooked? t))
  (adolist ((ensure-list types) elm)
    (log-events "Module ~A will catch ~A events.~%" _name !)
    (_hook-type ! callback-fun elm)))

(defmethod event-module _unhook-0 (obj)
 (= _handlers (remove-if [?
                           (function? obj)  (_.has-callback obj)
			               (element? obj)   (_.has-element obj)
			               (string? obj)    (_.has-type obj)]
                         _handlers)))

(defmethod event-module unhook (obj)
  (?
    (cons? obj)           (adolist obj
	                        (unhook !))
    (& (element? obj)
       obj._hooked?)      (_unhook-0 obj)
	(not (comment? obj))  (_unhook-0 obj)))

(defmethod event-module close ())

(defmethod event-module kill ()
  (*event-manager*.kill this))

(mapcar-macro _ *all-events*
  `(defmethod event-module ,(make-symbol (upcase _)) (fun elm)
     (this.hook ,_ fun elm)))

(finalize-class event-module)

(defmacro with-event-module (x &body body)
  `(with-temporary *event-module* ,x
     ,@body))

(defvar *event-module* (new event-module "default"))
