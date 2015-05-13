; tré – Copyright (c) 2015 Sven Michael Klose <pixel@hugbox.org>

(defbuiltin elt (seq idx)
  (& seq
     (cl:< idx (cl:length seq))
     (cl:elt seq idx)))

(defbuiltin %set-elt (obj seq idx)
  (cl:setf (cl:elt seq idx) obj))
