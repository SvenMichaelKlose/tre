;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Identifier style conversion

(defun transpiler-translate-symbol (tr from to)
  (acons! from to (transpiler-symbol-translations tr)))

(defun transpiler-special-char? (tr x)
  (not (funcall (transpiler-identifier-char? tr) x)))

(defun transpiler-symbol-string (tr s)
  (with (encapsulate-char
		   #'((x)
				(string-list (string-concat "T" (format nil "~A" (char-code x)))))
				
		 convert-camel
		   #'((x)
				(when x
			      (with (c (char-downcase (car x)))
			        (if (and (in=? c #\* #\-)
							 (cdr x))
						(cons (char-upcase (cadr x))
							  (convert-camel (cddr x)))
					    (cons c (convert-camel (cdr x)))))))

		 convert-special2
		   #'((x)
				(when x
			      (with (c (car x))
				    (if (transpiler-special-char? tr c)
					    (append (encapsulate-char c)
								(convert-special2 (cdr x)))
					    (cons c (convert-special2 (cdr x)))))))

		 convert-special
		   #'((x)
				(when x
			      (with (c (car x))
					; Encapsulate initial char if it's a digit.
				    (if (digit-char-p c)
					    (append (encapsulate-char c)
							    (convert-special2 (cdr x)))
						(convert-special2 x)))))

		 str (string s)
	     l (length str))

	(if (or (stringp s)
			(numberp s))
		str
        (list-string
	      (convert-special
            (if (and (< 2 (length str)) ; Make *GLOBAL* upcase.
			         (= (elt str 0) #\*)
			         (= (elt str (1- l)) #\*))
		        (remove-if #'((x)
						        (= x #\-))
					       (string-list (string-upcase (subseq str 1 (1- l)))))
    	        (convert-camel (string-list str))))))))

(defun transpiler-to-string (tr x)
  (maptree #'((e)
				(cond
				  ((consp e)   (if (eq (car e) '%transpiler-string)
								   (string-concat "\"" (cadr e) "\"")
								   (if (in? (car e) '%transpiler-native '%no-expex)
									   (transpiler-to-string tr (cdr e))
									   e)))
				  ((stringp e) e)
				  (t		   (aif (assoc e (transpiler-symbol-translations tr))
								   (cdr !)
								   (string-concat (transpiler-symbol-string tr e) " ")))))
		   x))
