;;;;; Caroshi ECMAScript library
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

,(with-open-file in (open "_current-version" :direction 'input)
   (let l (string-list (read-line in))
	 `(defvar *tre-revision*
	    ,(list-string
	         (aif (position #\: l)
		          (subseq l (1+ !) (or (position #\M l :test #'=)
								       999))
		          l)))))
