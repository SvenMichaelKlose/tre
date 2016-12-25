(defun debug-print-write (x)
  (%write-char x))

(defun debug-print-cons-r (x)
  (when x
    (debug-print x.)
    (? (cons? .x)
	   (debug-print-cons-r .x)
	   (when .x
		 (debug-print-write " . ")
		 (debug-print-atom .x)))))

(defun debug-print-cons (x)
  (debug-print-write "(")
  (debug-print-cons-r x)
  (debug-print-write ")"))

(defun debug-print-symbol (x)
  (when (keyword? x)
	(debug-print-write ":"))
  (debug-print-write (+ (symbol-name x) " ")))

(defun debug-print-character (x)
  (debug-print-write (+ "#\\\\" (*string.from-char-code (char-code x)))))

(defun debug-print-string (x)
  (debug-print-write (+ "\"" x "\"")))

(defun debug-print-object (x)
  (debug-print-write "{")
  (maphash #'((k v)
			    (debug-print k)
				(debug-print-write " => ")
				(debug-print v)
				(debug-print-write "<br/>"))
	       x)
  (debug-print-write "}<br/>"))

(defun debug-print-atom (x)
  (?
    (not x)		   (debug-print-write "NIL")
    (symbol? x)	   (debug-print-symbol x)
    (character? x) (debug-print-character x)
    (string? x)	   (debug-print-string x)
    (object? x)	   (debug-print-object x)
	(debug-print-write (+ "[unknown type: " (string x) "]"))))

(defun debug-print (x)
  (? (cons? x)
	 (debug-print-cons x)
	 (debug-print-atom x))
  x)
