;;;; TRE environment
;;;; Copyright (c) 2006-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; FORMAT function

(defun %format-directive (str l i txt args)
   (let el (char-upcase (elt txt i))
     (if
       (character= el #\%)
		 (progn
		   (terpri str)
           (%format str l (integer-1+ i) txt args))
       (character= el #\A)
		 (progn
		   (if args
		       (if (or (consp args.)
					   (variablep args.))
				   (late-print args. str) ; XXX
                   (princ args. str))
			   (error "argument specified in format is missing"))
           (%format str l (integer-1+ i) txt .args))
       (progn
		 (princ #\~ str)
         (%format str l i txt args)))))

(defun %format (str l i txt args)
  (when (integer< i l)
    (if (character= (elt txt i) #\~)
        (%format-directive str l (integer-1+ i) txt args)
        (progn
          (princ (elt txt i) str)
          (%format str l (integer-1+ i) txt args)))))

(defun format (str txt &rest args)
  "Print formatted string."
  (with-default-stream nstr str
    (%format nstr (length txt) 0 txt args)))
