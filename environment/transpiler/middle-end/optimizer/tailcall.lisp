(fn function-exits? (x)
  (| (not x)
     (?
       (%go? x.)
         (function-exits? (tag-code (%go-tag x.)))
       (| (some-%go? x.)
          (%=? x.))
         nil
       (function-exits? .x))))

(fn opt-tailcall-make-restart (l body front-tag)
  (optimizer-message "Resolved tail call in ~A.~%"
                     (!= (human-readable-funinfo-names *funinfo*)
                       (? .! ! !.)))
  (+ (+@ #'((arg val)
             `((%= ,arg ,val)))
         (funinfo-args *funinfo*)
         (cdr (caddr body.)))
     `((%go ,front-tag))
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

(metacode-walker opt-tailcall-body (x)
  :if-named-function
    (with-compiler-tag front-tag
      `(,front-tag
        ,@(opt-tailcall-fun x. (lambda-body x.) front-tag))))

(fn opt-tailcall (x)
  (!= (opt-tailcall-body x)
    (? (equal ! x)
       !
       (optimize !))))
