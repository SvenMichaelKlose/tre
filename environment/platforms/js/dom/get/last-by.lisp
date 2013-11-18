;;;;; tré – Copyright (c) 2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(mapcar-macro x
	'(tag class)
  (let n ($ '-by- x '-name)
    `(defun ,($ 'dom-get-last n) (doc name )
	   (let-when vec ((slot-value doc ',($ 'get-elements n)) name)
	     (let len (length vec)
		   (unless (== 0 len)
	         (aref vec (-- len))))))))
