; tré – Copyright (c) 2015 Sven Michael Klose <pixel@hugbox.org>

(defbuiltin elt (seq idx)
  (& seq
     (cl:< idx (cl:length seq))
     (cl:elt seq idx)))
