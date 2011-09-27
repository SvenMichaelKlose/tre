;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Identifier style conversion

(defun transpiler-translate-symbol (tr from to)
  (acons! from to (transpiler-symbol-translations tr)))

(defun transpiler-special-char? (tr x)
  (not (funcall (transpiler-identifier-char? tr) x)))

(defun transpiler-symbol-string-r (tr s)
  (with (encapsulate-char
		   (fn string-list (string-concat "T" (format nil "~A" (char-code _))))
				
		 convert-camel
		   (fn (when _
			     (with (c (char-downcase _.))
			       (? (and ._ (in=? c #\* #\-))
					  (cons (char-upcase (cadr _))
						    (convert-camel (cddr _)))
					  (cons c (convert-camel ._))))))

		 convert-special2
		   (fn (when _
			     (let c _.
				   (? (transpiler-special-char? tr c)
					  (append (encapsulate-char c)
							  (convert-special2 ._))
					  (cons c (convert-special2 ._))))))

		 convert-special
		   (fn (when _
			     (let c _.
				   ; Encapsulate initial char if it's a digit.
				   (? (digit-char-p c)
					  (append (encapsulate-char c)
							  (convert-special2 ._))
					  (convert-special2 _))))))
	(? (or (string? s)
		   (number? s))
	   (string s)
	   (with (str (string s)
	     	  l (length str))
         (list-string
	       (convert-special (? (and (< 2 (length str)) ; Make *GLOBAL* upcase.
			                        (= (elt str 0) #\*)
			                        (= (elt str (1- l)) #\*))
		                       (remove-if (fn = _ #\-) (string-list (string-upcase (subseq str 1 (1- l)))))
    	                       (convert-camel (string-list str)))))))))

(defun transpiler-symbol-string-0 (tr s)
  (aif (symbol-package s)
       (transpiler-symbol-string-r tr (make-symbol (string-concat (symbol-name !) ":" (symbol-name s))))
       (transpiler-symbol-string-r tr s)))

(defun transpiler-dot-symbol-string (tr sl)
  (apply #'string-concat (pad (mapcar (fn transpiler-symbol-string-0 tr (make-symbol (list-string _)))
		                              (split #\. sl))
                              ".")))

(defun transpiler-symbol-string (tr s)
  (let sl (string-list (string s))
    (? (position #\. sl)
	   (transpiler-dot-symbol-string tr sl)
	   (transpiler-symbol-string-0 tr s))))

(defun transpiler-to-string (tr x)
  (maptree #'((e)
				(?
				  (cons? e)
					(?
					  (%transpiler-string? e)
						(funcall (transpiler-gen-string tr) (cadr e))
					  (eq '%transpiler-native e.)
						(transpiler-to-string tr .e)
					  e)
				  (string? e)
					e
				  (or (assoc-value e (transpiler-symbol-translations tr) :test #'eq)
					  (string-concat (transpiler-symbol-string tr e)))))
		   x))
