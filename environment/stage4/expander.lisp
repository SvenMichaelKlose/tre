(var *expander-dump?* nil)

(defstruct expander
  name macros pred call pre post lookup
  user) ; For external use.

(fn expander-macro (expander macro-name)
  (href (expander-macros expander) macro-name))

(fn expander-argdef (expander macro-name)
  (car (expander-macro expander macro-name)))

(fn expander-function (expander macro-name)
  (cdr (expander-macro expander macro-name)))

;(fn (= expander-function) (new-function expander macro-name)
;  (= (cdr (href (expander-macros expander) macro-name)) new-function))

(fn expander-has-macro? (expander macro-name)
  (href (expander-macros expander) macro-name))

(fn define-expander (expander-name &key (pre nil) (post nil)
                                        (pred nil) (call nil))
  (aprog1 (make-expander :name    expander-name
                         :macros  (make-hash-table :test #'eq)
                         :pred    pred
                         :call    call
                         :pre     (| pre #'(nil))
                         :post    (| post #'(nil)))
    (| pred
       (= (expander-pred !)
          [& (cons? _)
             (symbol? _.)
             (expander-function ! _.)]))
    (| call
       (= (expander-call !)
          [*> (expander-function ! _.)
              (argument-expand-values _. (expander-argdef ! _.) ._)]))
    (= (expander-lookup !)
       #'((expander name)
           (href (expander-macros expander) name)))))

(fn set-expander-macro (expander name argdef fun &key (may-redefine? nil))
  (& (not may-redefine?)
     (expander-has-macro? expander name)
     (warn "Macro ~A already defined for expander ~A."
           name (expander-name expander)))
  (= (href (expander-macros expander) name) (. argdef fun)))

(fn set-expander-macros (expander x)
  (mapcar [set-expander-macro expander _. ._. .._] x))

(defmacro def-expander-macro (expander name args &body body)
  `(set-expander-macro ,expander ',name ',args
     #'(,(argument-expand-names 'def-expander-macro args)
         ,@body)))

(fn expander-expand-0 (expander expr)
  (with-temporaries (*macro?*     (expander-pred expander)
                     *macrocall*  (expander-call expander))
    (!= (expander-name expander)
      (? (eq ! *expander-dump?*)
         (progn
           (format t "~%; Expander ~A input:~%" !)
           (print expr)
           (format t "~%; Expander ~A output:~%" !)
           (print (%macroexpand expr)))
         (%macroexpand expr)))))

(fn expander-expand (expander expr)
  (| (expander? expander)
     (error "Expander ~A is not defined." (expander-name expander)))
  (~> (expander-pre expander))
  (prog1 (refine [expander-expand-0 expander _] expr)
    (~> (expander-post expander))))
