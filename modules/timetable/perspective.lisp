(defclass perspective ()
  (= _x 0
     _y 0
     _z 0
     _static-x 0
     _static-y 0
     _static-z 0
     _forced-z nil)
  this)

(defmember perspective
  _element
  _x
  _y
  _z
  _static-x
  _static-y
  _static-z
  _original-width
  _original-height
  _forced-z)

,(alet '(:class perspective)
   `(progn
      (define-get-alias element _element ,@!)
      ,@(@ [`(define-getset-alias ,_ ,($ '_ _) ,@!)]
           '(x y z
             static-x static-y static-z
             forced-z
             original-width original-height))))

(defmethod perspective set-position (x y z)
  (set-x x)
  (set-y y)
  (set-z z))

(defmethod perspective set-static-position (x y z)
  (set-static-x x)
  (set-static-y y)
  (set-static-z z))

(defmethod perspective _set-size (w h)
  (_element.set-width w)
  (_element.set-height h))

(defmethod perspective set-size (w h)
  (_set-size w h))

(fn project (v z)
  (* 1000 (/ v (? (== 0 z) 1 z))))

(defmethod perspective _transform (x)
  (project x _z))

(defmethod perspective _update ()
  (with (cx (- _x (half _original-width))
         cy (- _y (half _original-height))
         cx2 (+ _x (half _original-width))
         cy2 (+ _y (half _original-height))
         px (_transform cx)
         py (_transform cy)
         px2 (_transform cx2)
         py2 (_transform cy2)
         w (- px2 px)
         h (- py2 py)
         (vx vy vw vh) (get-viewport)
         rat (/ vw 1024)
         fx (+ (* px rat) (half vw))
         fy (+ (* py rat) (half vh))
         fw (* w rat)
         fh (* h rat))
    (_element.set-position fx fy)
    (set-size fw fh)
    (? (<= _z 30)
       (_element.hide)
       (_element.show))
    (_element.set-style "zIndex" (| _forced-z (- 65535 (*math.floor _z))))))

(defmethod perspective update ()
  (_update))

(defmethod perspective clear ()
  (_element.hide))

(defmethod perspective _init-element (x width height)
  (= _element x)
  (_element.hide)
  (_element.add-class "pagefaderkeep")
  (_element.set-style "position" "absolute")
  ;(_element.set-width width)
  ;(_element.set-height height)
  (= _original-width width)
  (= _original-height height))

(finalize-class perspective)
