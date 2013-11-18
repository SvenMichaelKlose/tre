;;;;; tré – Copyright (c) 2009,2011 Sven Michael Klose <pixel@copei.de>

(mapcar-macro x
	'(-tag -class "")
  (let n ($ '-by x '-name)
    `(defun ,($ 'dom-get-first n) (doc name )
	   (aref ((slot-value doc ',($ 'get-elements n)) name)
			 0))))
