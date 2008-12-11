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
		   (fn string-list (string-concat "T" (format nil "~A" (char-code _))))
				
		 convert-camel
		   (fn (when _
			     (with (c (char-downcase _.))
			       (if (and (in=? c #\* #\-)
							._)
					   (cons (char-upcase (cadr _))
							 (convert-camel (cddr _)))
					   (cons c (convert-camel ._))))))

		 convert-special2
		   (fn (when _
			     (with (c _.)
				   (if (transpiler-special-char? tr c)
					   (append (encapsulate-char c)
							   (convert-special2 ._))
					   (cons c (convert-special2 ._))))))

		 convert-special
		   (fn (when _
			     (with (c _.)
				   ; Encapsulate initial char if it's a digit.
				   (if (digit-char-p c)
					   (append (encapsulate-char c)
							   (convert-special2 ._))
					   (convert-special2 _)))))

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
		        (remove-if (fn = _ #\-)
					       (string-list (string-upcase (subseq str 1 (1- l)))))
    	        (convert-camel (string-list str))))))))

(defun transpiler-to-string (tr x)
  (maptree #'((e)
				(if
				  (consp e)
					(if (eq e. '%transpiler-string)
					    (string-concat "\"" (cadr e) "\"")
						(if (in? e. '%transpiler-native '%no-expex)
							(transpiler-to-string tr .e)
							e))
				  (stringp e)
					e
				  (aif (assoc e (transpiler-symbol-translations tr))
						.!
						(string-concat (transpiler-symbol-string tr e) " "))))
		   x))
