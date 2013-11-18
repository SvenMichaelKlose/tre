;;;;; tré – Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

(defun previous-sibling-by-class (x class-name)
  (do-previous-siblings (i x nil)
    (& (element? i) (i.has-class? class-name)
       (return i))))

(defun next-sibling-by-class (x class-name)
  (do-next-siblings (i x nil)
    (& (element? i) (i.has-class? class-name)
       (return i))))

(def-aos-if ancestor-or-self-with-previous-sibling-by-class (class-name)
  (fn previous-sibling-by-class _ class-name))
