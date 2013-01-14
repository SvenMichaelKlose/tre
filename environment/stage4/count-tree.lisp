;;;;; tré – Copyright (c) 2009–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun count-tree (v x &key (test #'eql) (counter 0))
  (?
	(atom x) (? (funcall test v x)
                (integer-1+ counter)
                counter)
    (integer+ (count-tree v x. :test test :counter counter)
              (count-tree v .x :test test :counter counter))))
