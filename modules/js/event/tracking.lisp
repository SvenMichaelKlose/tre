(document-extend)


(var *key-stats* (make-array))
(var *shift-down?* nil)
(var *ctrl-down?* nil)
(var *alt-down?* nil)

(fn get-key-stat (code)
  (unless (undefined? (aref *key-stats* code))
    (aref *key-stats* code)))

(fn update-keystat (evt)
  (= (aref *key-stats* evt.key-code) (eql evt.type "keydown"))
  (= *shift-down?* (get-key-stat 16)
     *ctrl-down?*  (get-key-stat 17)
     *alt-down?*   (get-key-stat 18)))

(document.keyup update-keystat)
(document.keydown update-keystat)


(var *pointer-x* 0)
(var *pointer-y* 0)

(document.mousemove [(= *pointer-x* _.page-x
                        *pointer-y* _.page-y)])


(var *last-hovered* nil)

(document.mouseover [= *last-hovered* _.target])
