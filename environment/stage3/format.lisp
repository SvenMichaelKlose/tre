;;;; TRE environment
;;;; Copyright (c) 2006-2008,2011 Sven Klose <pixel@copei.de>
;;;;
;;;; FORMAT function

(defvar *format-handlers* nil)

(defmacro define-format (chr (str l i txt args) &rest body)
  (with-gensym g
    `(progn
       (defun ,g (,str ,l ,i ,txt ,args)
         ,@body)
       (acons! ,chr #',g *format-handlers*))))

(define-format #\% (str l i txt args)
  (terpri str)
  (values (integer-1+ i) args))

(define-format #\A (str l i txt args)
  (? args
     (? (or (cons? args.)
			(variablep args.))
		(late-print args. str) ; XXX
        (princ args. str))
	 (error "argument specified in format is missing"))
  (values (integer-1+ i) .args))

(defun %format-directive (str l i txt args)
  (let el (char-upcase (elt txt i))
    (aif (assoc-value el *format-handlers* :test #'character=)
         (with ((new-index next-args) (funcall ! str l (integer-1+ i) txt args))
           (%format str l new-index txt next-args))
         (progn
		   (princ #\~ str)
           (%format str l (integer-1+ i) txt args)))))

(defun %format (str l i txt args)
  (when (integer< i l)
    (? (character= (elt txt i) #\~)
       (%format-directive str l (integer-1+ i) txt args)
       (progn
         (princ (elt txt i) str)
         (%format str l (integer-1+ i) txt args)))))

(defun format (str txt &rest args)
  "Print formatted string."
  (with-default-stream nstr str
    (%format nstr (length txt) 0 txt args)))
