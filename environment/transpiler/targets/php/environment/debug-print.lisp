;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>

(defun debug-print-write (x doc)
  (setf doc.body.inner-h-t-m-l
  	    (+ doc.body.inner-h-t-m-l x)))

(defun debug-print-cons-r (x doc)
  (when x
    (debug-print x. doc)
    (? (consp .x)
	   (debug-print-cons-r .x doc)
	   (when .x
		 (debug-print-write " . " doc)
		 (debug-print-atom .x doc)))))

(dont-obfuscate write)

(defun debug-print-cons (x doc)
  (debug-print-write "(" doc)
  (debug-print-cons-r x doc)
  (debug-print-write ")" doc))

(defun debug-print-symbol (x)
  (+ (? (keywordp x) ":" "")
	 (symbol-name x)))

(defun debug-print-object (x)
  (+ "{"
     (apply #'+ (map (fn (+ _ " => " (href x _) "<br/>")) x))
	"}<br/>"))

(defun debug-print-atom (x doc)
  (debug-print-write
      (+ (?
	       (symbolp x)
	         (debug-print-symbol x)
	       (characterp x)
		     (+ "#\\\\" (*string.from-char-code (char-code x)))
	       (arrayp x)
	         "{array}"
	       (string? x)
	         (+ "\"" x "\"")
		   (when x
	         (? (objectp x)
			     (debug-print-object x)
		   	     (string x))))
	     " ")
	doc))

(dont-inline debug-print)

(defun debug-print (x &optional (doc logwindow.document))
  (? (consp x)
	 (debug-print-cons x doc)
	 (debug-print-atom x doc))
  x)
