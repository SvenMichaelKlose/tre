;;;; tré – Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

(progn
  ,@(mapcar (fn `(= (slot-value userfun_event-module.prototype ,(list 'quote (make-symbol (string-upcase _))))
                    #'((fun elm)
                         (this.hook ,_ fun elm))))
            '("click" "dblclick"
              "mousemove" "mouseover" "mouseout"
              "mousedownright" "mousedownleft"
              "submit"
              "change"
              "focus" "blur"
              "contextmenu"
              "online" "offline"
              "unload"
              "play" "ended"
              "dragenter" "dragover"
              "keypress" "keydown" "keyup"
              "mouseup" "mousedown" "drop" "unload"
              "text-modified" "document-modified")))