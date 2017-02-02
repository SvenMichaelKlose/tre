(var *=-function?* #'%=-function?)

(fn =-make-symbol (fun)
  (make-symbol (string-concat "=-" (symbol-name fun))))

(fn =-complement (p val)
  (? (| (atom p)
	    (%slot-value? p)
	    (slot-value? p))
	 {(? (member p *constants* :test #'eq)
	     (error "Cannot set constant ~A." p))
      (list 'setq p val)}
     (let* ((fun     p.)
	        (args    .p)
	        (setter  (=-make-symbol fun)))
       (? (funcall *=-function?* setter)
		  (? (member args. *constants* :test #'eq)
		   	 (error "Cannot set constant ~A." args)
	         `(,setter ,val ,@args))
          (error "Place ~A isn't settable." p)))))

(fn =-0 (args)
  (? (not .args)
     (error "Pair expected instead of single ~A." args.)
     (. (=-complement args. .args.)
        (? ..args
           (=-0 ..args)))))

(defmacro = (&rest args)
  (? args
     (? .args
        `{,@(=-0 args)}
        `(= ,args.))
     (error "Arguments expected.")))
