; Holy Moly!

; All event names prefixed by "ON-".
(var *lml-hook-attrs* (@ [. (make-keyword (upcase (+ "on-" _))) _] *all-events*))

(fn lml-hook-attr? (x)
  (assoc-value x *lml-hook-attrs*))

(define-lml-macro %hook (event-names handler child)
  "Wrapper around single child elements to attach an event listener to it."
  `(%exec ,#'((parent child)
               (@ (i (ensure-list event-names))
                 (child.add-event-listener i handler)))
     ,child))

(fn lml-hook (x)
  "Called by $$, LML-HOOK wraps all elements with \"ON-<event name>\" attributes in %HOOK expressions
to have event listeners attached to them when generating the DOM.
I don't doubt the slightest that this could be easier to read. (pixel)"
  (? (atom x)
     x
     (with-queue q
       (with (f  [?
                   (atom _)
                     _
                   (keyword? _.)
                     (!? (lml-hook-attr? _.)
                         (progn
                           (enqueue q !)
                           (enqueue q ._.)
                           (f .._))
                         (. _. (. ._. (f .._))))
                   (cons? _.)     (. (lml-hook _.) (f ._))
                   (. _. (f ._))]
               m  #'((x elm)
                      (? x
                         `(%hook ,x. ,.x. ,(m ..x elm))
                         elm)))
         (let other-args (f .x)
           (!? (queue-list q)
               (m ! `(,x. ,@other-args))
               `(,x. ,@other-args)))))))
