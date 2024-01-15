(defclass videobuffer (&key (width nil) (height nil)
                            (high nil) (low nil) (webm nil)
                            (loop? nil))
  (_init width height high low webm loop?)
  (buffer-update))

(defmember videobuffer _element _canvas _width _height)

(define-get-alias element _element :class videobuffer)
(define-get-alias canvas _canvas :class videobuffer)

(defmethod videobuffer _init (width height high low webm loop?)
  (with (video (make-video :width width :height height
                           :high high :low low :webm webm
                           :loop? loop?)
         (can ctx) (make-canvas (new :width width :height height)))
    (video.play)
    (= _element video
       _canvas can
       _width width
       _height height)))

(defmethod videobuffer buffer-update ()
  (with-canvas-context "2d" ctx _canvas
    (ctx.draw-image _element 0 0 (integer _width) (integer _height))))

(finalize-class videobuffer)
