; TODO: Add all event names. (pixel)

(const *mouse-events*             '("click" "dblclick"
                                    "mouseup" "mousedown"
                                    "mousemove"
                                    "mouseover" "mouseout"))
(const *touch-events*             '("touchstart" "tochend" "touchmove" "touchcancel"))
(const *ignored-dragndrop-events* '("dragenter" "dragstart" "dragover"))
(const *key-events*               '("keypress" "keydown" "keyup"))
(const *form-events*              '("submit" "change" "input" "focus" "blur"))
(const *network-events*           '("online" "offline"))
(const *other-events*             '("contextmenu" "drop" "unload" "text-modified"))

(const *all-events* (+ *mouse-events* *touch-events* *ignored-dragndrop-events*
                       *key-events*
                       *form-events*
                       *network-events*
                       *other-events*))

(const *non-generic-events* `("mouseup" "mousedown"
                              ,@*ignored-dragndrop-events* "drop"
                              ,@*key-events*
                              "unload"))
