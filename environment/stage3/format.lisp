;;;;; tré - Copyright (c) 2006-2008,2011-2012 Sven Michael Klose <pixel@copei.de>

(defvar *format-handlers* nil)

(defmacro define-format (chr (str l i txt args) &rest body)
  (with-gensym g
    `(progn
       (defun ,g (,str ,l ,i ,txt ,args)
         ,@body)
       (acons! ,chr #',g *format-handlers*))))

(define-format #\% (str l i txt args)
  (terpri str)
  (values i args))

(define-format #\A (str l i txt args)
  (? args
     (? (or (cons? args.)
			(variablep args.))
		(late-print args. str) ; XXX
        (princ args. str))
	 (error "argument specified in format is missing"))
  (values i .args))

(defun %format-directive (str l i txt args)
   (let el (char-upcase (elt txt i))
     (?
       (character= el #\%)
		 (progn
		   (terpri str)
           (%format str l (integer-1+ i) txt args))
       (character= el #\A)
		 (progn
		   (? args
		      (? (or (cons? args.)
					  (variablep args.))
				 (late-print args. str) ; XXX
                 (princ args. str))
			  (error "argument specified in format is missing"))
           (%format str l (integer-1+ i) txt .args))
       (progn
		 (princ #\~ str)
         (%format str l i txt args)))))

(defun %format (str l i txt args)
  (while (integer< i l)
         nil
    (? (character= (elt txt i) #\~)
       (return (%format-directive str l (integer-1+ i) txt args))
       (progn
         (princ (elt txt i) str)
         (setf i (integer-1+ i))))))

(defun format (str txt &rest args)
  "Print formatted string."
  (with-default-stream nstr str
    (%format nstr (length txt) 0 txt args)))
