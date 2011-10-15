;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>

(defun js-print-write (x doc)
  (setf doc.body.inner-h-t-m-l
  	    (+ doc.body.inner-h-t-m-l x)))

(defun js-print-cons-r (x doc)
  (when x
    (js-print x. doc)
    (? (cons? .x)
	   (js-print-cons-r .x doc)
	   (when .x
		 (js-print-write " . " doc)
		 (js-print-atom .x doc)))))

(dont-obfuscate write)

(defun js-print-cons (x doc)
  (js-print-write "(" doc)
  (js-print-cons-r x doc)
  (js-print-write ")" doc))

(defun js-print-symbol (x doc)
  (when (keyword? x)
	(js-print-write ":" doc))
  (js-print-write (+ (symbol-name x) " ") doc))

(defun js-print-character (x doc)
  (js-print-write (+ "#\\\\" (*string.from-char-code (char-code x)))
				  doc))

(defun js-print-string (x doc)
  (js-print-write (+ "\"" x "\"") doc))

(defun js-print-object (x doc)
  (js-print-write "{" doc)
  (maphash #'((k v)
			    (js-print k doc)
				(js-print-write " => " doc)
				(js-print v doc)
				(js-print-write "<br/>" doc))
	       x)
  (js-print-write "}<br/>" doc))

(defun js-print-atom (x doc)
  (?
    (not x)		   (js-print-write "NIL" doc)
    (symbol? x)	   (js-print-symbol x doc)
    (character? x) (js-print-character x doc)
    (string? x)	   (js-print-string x doc)
    (object? x)	   (js-print-object x doc)
	(js-print-write (+ "[unknown type: " (string x) "]")
					doc)))

(dont-inline js-print)

(defun js-print (x &optional (doc logwindow.document))
  (? (cons? x)
	 (js-print-cons x doc)
	 (js-print-atom x doc))
  x)
