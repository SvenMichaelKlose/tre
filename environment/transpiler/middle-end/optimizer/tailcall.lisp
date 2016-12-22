; tré – Copyright (c) 2010–2014,2016 Sven Michael Klose <pixel@copei.de>

(defun function-exits? (x)
  (alet x.
    (?
	  (not x)          t
	  (%%go? !)        (!? (member .!. .x)
		                   (function-exits? .!))
	  (| (vm-jump? !)
	     (%=? !))      nil
	  (function-exits? .x))))

(defun opt-tailcall-make-restart (l body front-tag)
  (print-note "Removed tail call in ~A.~%"
              (human-readable-funinfo-names *funinfo*))
  (+ (mapcan #'((arg val)
                  `((%= ,arg ,val)))
             (funinfo-args *funinfo*)
             (cdr (caddr body.)))
     `((%%go ,front-tag))
     (opt-tailcall-fun l .body front-tag)))

(defun opt-tailcall-fun (l body front-tag)
  (with-lambda name args dummy-body l 
    (& body
       (? (& (%=-funcall-of? body. name)
             (function-exits? .body))
          (opt-tailcall-make-restart l body front-tag)
          (. (? (named-lambda? body.)
                (car (opt-tailcall `(,body.)))
                body.)
             (opt-tailcall-fun l .body front-tag))))))

(metacode-walker opt-tailcall (x)
  :if-named-function (with-compiler-tag front-tag
                       `(,front-tag
                         ,@(opt-tailcall-fun x. (lambda-body x.) front-tag))))
