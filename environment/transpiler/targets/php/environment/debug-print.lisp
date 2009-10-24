;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun js-print-write (x doc)
  (setf doc.body.inner-h-t-m-l
  	    (+ doc.body.inner-h-t-m-l x)))

(defun js-print-cons-r (x doc)
  (when x
    (js-print x. doc)
    (if (consp .x)
	    (js-print-cons-r .x doc)
	    (when .x
		  (js-print-write " . " doc)
		  (js-print-atom .x doc)))))

(dont-obfuscate write)

(defun js-print-cons (x doc)
  (js-print-write "(" doc)
  (js-print-cons-r x doc)
  (js-print-write ")" doc))

(defun js-print-symbol (x)
  (+ (if (keywordp x)
		 ":"
		 "")
	 (symbol-name x)))

(defun js-print-object (x)
  (+ "{"
     (apply #'+ (map (fn (+ _ " => " (href x _) "<br/>"))
				     x))
	"}<br/>"))

(defun js-print-atom (x doc)
  (js-print-write
      (+ (if
	       (symbolp x)
	         (js-print-symbol x)
	       (characterp x)
		     (+ "#\\\\" (*string.from-char-code (char-code x)))
	       (arrayp x)
	         "{array}"
	       (stringp x)
	         (+ "\"" x "\"")
		   (when x
	         (if (objectp x)
			     (js-print-object x)
		   	     (string x))))
	     " ")
	doc))

(dont-inline js-print)

(defun js-print (x &optional (doc logwindow.document))
  (if (consp x)
	  (js-print-cons x doc)
	  (js-print-atom x doc))
  x)
