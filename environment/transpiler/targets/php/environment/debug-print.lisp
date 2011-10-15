;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>

(defun debug-print-write (x doc)
  (setf doc.body.inner-h-t-m-l
  	    (+ doc.body.inner-h-t-m-l x)))

(defun debug-print-cons-r (x doc)
  (when x
    (debug-print x. doc)
    (? (cons? .x)
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
  (+ (? (keyword? x) ":" "")
	 (symbol-name x)))

(defun debug-print-object (x)
  (+ "{"
     (apply #'+ (map (fn (+ _ " => " (href x _) "<br/>")) x))
	"}<br/>"))

(defun debug-print-atom (x doc)
  (debug-print-write
      (+ (?
	       (symbol? x) (debug-print-symbol x)
	       (character? x) (+ "#\\\\" (*string.from-char-code (char-code x)))
	       (array? x) "{array}"
	       (string? x) (+ "\"" x "\"")
		   (when x
	         (? (object? x)
			     (debug-print-object x)
		   	     (string x))))
	     " ")
	doc))

(dont-inline debug-print)

(defun debug-print (x &optional (doc logwindow.document))
  (? (cons? x)
	 (debug-print-cons x doc)
	 (debug-print-atom x doc))
  x)
