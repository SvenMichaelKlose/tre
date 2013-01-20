;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defvar *opt-peephole?* t)

(defmacro opt-peephole-rec (a d val fun name &optional (setq? nil))
  `(with (plc (when (%setq? ,a)
			    (%setq-place ,a))
		  body (lambda-body ,val))
     (let f (copy-lambda ,val
                         :name ,name
                         :body (with-temporaries (*body*    body
                                                  *funinfo* (get-lambda-funinfo ,val))
                                 (,fun body)))
       (cons ,(? setq?
	            '`(%setq ,plc ,f)
			    'f)
		     (,fun ,d)))))

(defmacro opt-peephole-fun (fun &rest body)
  `(when x
	 (with-cons a d x
	   (?
		 (named-lambda? a) (opt-peephole-rec a d ..a. ,fun .a.)
		 (%setq-lambda? a) (opt-peephole-rec a d (%setq-value a) ,fun nil t)
		 ,@body
		 t (cons a (,fun d))))))

(defmacro def-opt-peephole-fun (name &rest body)
  `(defun ,name (x)
     (opt-peephole-fun ,name
       ,@body)))
