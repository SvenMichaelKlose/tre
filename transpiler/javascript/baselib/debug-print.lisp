;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun js-print-cons-r (x)
  (when x
    (js-print x.)
    (if (consp .x)
	    (js-print-cons-r .x)
	    (when .x
		  (document.write " . ")
		  (document.write .x)))))

(defun js-print-cons (x)
  (document.write "(")
  (js-print-cons-r x)
  (document.write ")"))

(defun js-print (x)
  (if
	(consp x)
	  (js-print-cons x)
	(document.write
	  (+ (if
		   (symbolp x)
	         (symbol-name x)
	       (characterp x)
		     (+ "#\\\\" (*string.from-char-code (char-code x)))
	       (arrayp x)
	         "{array}"
	       (stringp x)
	         (+ "\\\"" x "\\\"")
		   (when x
			 (string x)))
		 " ")))
  x)
