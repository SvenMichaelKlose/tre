;;;;; tré – Copyright (c) 2005–2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun %compiled-atom (x quoted?)
  (? (& quoted? x (symbol? x))
     (list 'quote x)
     x))

(defun compiled-list (x &key (quoted? nil))
  (? (cons? x)
     `(cons ,(%compiled-atom x. quoted?)
            ,(compiled-list .x :quoted? quoted?))
	 (%compiled-atom x quoted?)))

(defun compiled-tree (x &key (quoted? nil))
  (? (cons? x)
     `(cons ,(compiled-tree x. :quoted? quoted?)
            ,(compiled-tree .x :quoted? quoted?))
	 (%compiled-atom x quoted?)))
