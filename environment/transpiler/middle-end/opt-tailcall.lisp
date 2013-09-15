;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defun function-exits? (x)
  (alet x.
    (?
	  (not x)          t
	  (| (vm-jump? !)
	     (%setq? !))   nil
	  (%%go? !)        (!? (member .!. .x :test #'integer==)
		                   (function-exits? .!))
	  (function-exits? .x))))

(defun opt-tailcall-make-restart (l body front-tag)
  (with-lambda name args dummy-body l 
    (& *show-definitions?*
       (format t "; Removing tail call in function ~A.~%" name))
    (+ (mapcan #'((arg val)
                    (with-gensym g ; Avoid accidential GC.
                      `((%setq ,arg ,val))))
               (argument-expand-names name args)
               (cdr (%setq-value body.)))
       `((%%go ,front-tag))
       (opt-tailcall-fun l .body front-tag))))

(defun opt-tailcall-fun (l body front-tag)
  (with-lambda name args dummy-body l 
    (& body
       (? (& (%setq-funcall-of? body. name)
             (function-exits? .body))
          (opt-tailcall-make-restart l body front-tag)
          (cons (? (named-lambda? body.)
                   (car (opt-tailcall `(,body.)))
                   body.)
                (opt-tailcall-fun l .body front-tag))))))

(metacode-walker opt-tailcall (x)
  :if-named-function  (with-compiler-tag front-tag
                        `(,front-tag
                          ,@(opt-tailcall-fun x. (lambda-body x.) front-tag))))
