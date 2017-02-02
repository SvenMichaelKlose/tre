(fn function-exits? (x)
  (alet x.
    (?
	  (not x)          t
	  (%%go? !)        (!? (member .!. .x)
		                   (function-exits? .!))
	  (| (vm-jump? !)
	     (%=? !))      nil
	  (function-exits? .x))))

(fn opt-tailcall-make-restart (l body front-tag)
  (developer-note "Removed tail call in ~A.~%"
                  (human-readable-funinfo-names *funinfo*))
  (+ (mapcan #'((arg val)
                  `((%= ,arg ,val)))
             (funinfo-args *funinfo*)
             (cdr (caddr body.)))
     `((%%go ,front-tag))
     (opt-tailcall-fun l .body front-tag)))

(fn opt-tailcall-fun (l body front-tag)
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
