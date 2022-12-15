(defclass (perspective-video perspective) (width height &key (high nil) (low nil) (webm nil) (swf nil) (loop? nil) (autoplay? nil))
  (super)
  (set-url width height high low webm swf loop? autoplay?)
  this)

(defmethod perspective-video set-url (width height high low webm swf loop? autoplay?)
  (let video (make-video :width width :height height
                         :high high :low low :webm webm :swf swf
                         :loop? loop? :autoplay? autoplay?)
    (document.body.add video)
    (_init-element video width height)))

(defmethod perspective-video set-size (width height)
  (_set-size width height)
  (let-when emb (_element.get "embed")
    (emb.write-attribute "width" width)
    (emb.write-attribute "height" height)
    (emb.set-width width)
    (emb.set-height height)))

(finalize-class perspective-video)
