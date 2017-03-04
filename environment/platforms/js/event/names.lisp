(const *mouse-events*             '("click" "dblclick" "mouseup" "mousedown" "mousemove" "mouseover" "mouseout"
                                    "mouseupleft" "mouseupmiddle" "mouseupright"
                                    "mousedownleft" "mousedownmiddle" "mousedownright"))
(const *touch-events*             '("touchdown" "touchmove" "touchup"))
(const *ignored-dragndrop-events* '("dragenter" "dragover"))
(const *key-events*               '("keypress" "keydown" "keyup"))
(const *form-events*              '("submit" "change" "input" "focus" "blur"))
(const *media-events*             '("play" "ended"))
(const *network-events*           '("online" "offline"))
(const *other-events*             '("contextmenu" "drop" "unload"))

(const *all-events* (+ *mouse-events* *touch-events* *ignored-dragndrop-events*
                       *key-events* *form-events*
                       *media-events* 
                       *network-events*
                       *other-events*))

(const *non-generic-events* `("mouseup" "mousedown" ,@*ignored-dragndrop-events* "drop" ,@*key-events* "unload"))
