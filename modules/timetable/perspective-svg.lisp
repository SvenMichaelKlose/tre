(defclass (perspective-svg perspective) (url width height)
  (super)
  (set-url url width height))

(defmethod perspective-svg set-url (url width height)
  (let img ($$ `(object :data ,url
                        :type "image/svg+xml"
                        :width ,width :height ,height))
    (= img.src url)
    (document.body.add img)
    (_init-element img width height)))

(finalize-class perspective-svg)
