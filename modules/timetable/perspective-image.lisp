(defclass (perspective-image perspective) (&optional (url nil) (width nil) (height nil))
  (super)
  (set-url url width height)
  this)

(defmethod perspective-image set-url (url width height)
  (when url
    (let img ($$ '(img))
      (= img.src url)
      (document.body.add img)
      (_init-element img (| width (img.get-width)) (| height (img.get-height))))))

(finalize-class perspective-image)
