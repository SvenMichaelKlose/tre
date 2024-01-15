(defclass (perspective-video perspective) (width height
                                           &key (high nil) (low nil)
                                                (webm nil) (swf nil)
                                                (loop? nil) (autoplay? nil))
  (super)
  (set-url width height high low webm swf loop? autoplay?))

(defmethod perspective-video set-url (width height high low webm swf
                                      loop? autoplay?)
  (!= (make-video :width width :height height
                  :high high :low low :webm webm :swf swf
                  :loop? loop? :autoplay? autoplay?)
    (document.body.add !)
    (_init-element ! width height)))

(defmethod perspective-video set-size (width height)
  (_set-size width height)
  (awhen (_element.get "embed")
    (!.write-attribute "width" width)
    (!.write-attribute "height" height)
    (!.set-width width)
    (!.set-height height)))

(finalize-class perspective-video)
