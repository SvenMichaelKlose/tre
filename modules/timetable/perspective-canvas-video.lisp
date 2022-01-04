(defclass (perspective-canvas-video perspective-canvas) (&key video (x nil) (y nil) (width nil) (height nil))
  (super width height)
  (= _video video
     _video-x x
     _video-y y
     _video-width width
     _video-height height)
  this)

(defmember perspective-canvas-video _video _video-x _video-y _video-width _video-height)

(defmethod perspective-canvas-video buffer-update ()
  (unless (| _video.paused _video.ended)
    (with-canvas-context "2d" ctx (_video.get-canvas)
      (let tile (ctx.get-image-data (integer _video-x) (integer _video-y) (integer _video-width) (integer _video-height))
        (with-canvas-context "2d" ctx (get-element)
          (ctx.put-image-data tile 0 0 (integer _video-width) (integer _video-height)))))))

(finalize-class perspective-canvas-video)
