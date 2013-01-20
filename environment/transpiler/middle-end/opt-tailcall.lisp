;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defun opt-tailcall-fun-0 (fi args x name front-tag)
  (+ (mapcan #'((arg val)
                  (with-gensym g ; Avoid accidential GC.
                    (funinfo-var-add fi g)
                    (funinfo-add-immutable fi g)
                    `((%setq ,arg ,val)
                      (%setq ,g ,arg))))
             (argument-expand-names name args)
             (cdr (%setq-value x.)))
     `((%%vm-go ,front-tag))
     (opt-tailcall-fun fi args .x name front-tag)))

(defun function-will-exit? (fi x)
  (?
	(not x)          t
	(%%vm-go? x.)    (& (member (cadr x.) .x :test #'eq)
		                (function-will-exit? fi .x))
	(| (vm-jump? x.)
	   (%setq? x.))  nil
	(function-will-exit? fi .x)))

(defun opt-tailcall-fun (fi args x name front-tag)
  (when x
    (? (& (%setq-funcall-of? x. name)
  		  (function-will-exit? fi .x))
	   (opt-tailcall-fun-0 fi args x name front-tag)
	   (cons x. (opt-tailcall-fun fi args .x name front-tag)))))

(metacode-walker opt-tailcall (x)
  :if-named-function
      (with (front-tag (make-compiler-tag)
             x x.)
        `(,front-tag
          ,@(opt-tailcall-fun (get-lambda-funinfo x)
                              (lambda-args x)
                              (lambda-body x)
                              (lambda-name x)
                              front-tag))))
