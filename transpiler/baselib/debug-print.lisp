;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun js-print-cons-r (x doc)
  (when x
    (js-print x. doc)
    (if (consp .x)
	    (js-print-cons-r .x doc)
	    (when .x
		  (doc.write " . ")
		  (js-print-atom .x doc)))))

(defun js-print-cons (x doc)
  (doc.write "(")
  (js-print-cons-r x doc)
  (doc.write ")"))

(defun js-print-symbol (x)
  (+ (if (keywordp x)
		 ":"
		 "")
	 (symbol-name x)))

(defun js-print-atom (x doc)
  (doc.write
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
		   (string x)))
	   " ")))

(defun js-print (x &optional (doc logwindow.document))
  (if (consp x)
	  (js-print-cons x doc)
	  (js-print-atom x doc))
  x)
