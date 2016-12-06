; tré – Copyright (c) 2006–2009,2011–2016 Sven Michael Klose <pixel@copei.de>

(defvar *expander-dump?* nil)

(defstruct expander
  name
  macros
  pred
  call
  pre
  post
  lookup
  user) ; For external use.

(defun expander-macro (expander macro-name)
  (href (expander-macros expander) macro-name))

(defun expander-argdef (expander macro-name)
  (car (expander-macro expander macro-name)))

(defun expander-function (expander macro-name)
  (cdr (expander-macro expander macro-name)))

;(defun (= expander-function) (new-function expander macro-name)
;  (= (cdr (href (expander-macros expander) macro-name)) new-function))

(defun expander-has-macro? (expander macro-name)
  (href (expander-macros expander) macro-name))

(defun define-expander (expander-name &key (pre nil) (post nil) (pred nil) (call nil))
  (aprog1 (make-expander :name expander-name
                         :macros (make-hash-table :test #'eq)
                         :pred pred
                         :call call
                         :pre (| pre #'(nil))
                         :post (| post #'(nil)))
    (| pred
       (= (expander-pred !) [& (cons? _)
                               (symbol? _.)
	                           (expander-function ! _.)]))
    (| call
       (= (expander-call !) [apply (expander-function ! _.)
                                   (argument-expand-values _. (expander-argdef ! _.) ._)]))
    (= (expander-lookup !)
       #'((expander name)
           (href (expander-macros expander) name)))))

(defun set-expander-macro (expander name argdef fun &key (may-redefine? nil))
  (& (not may-redefine?)
     (expander-has-macro? expander name)
     (warn "Macro ~A already defined for expander ~A." name (expander-name expander)))
  (= (href (expander-macros expander) name) (. argdef fun)))

(defun set-expander-macros (expander x)
  (map [set-expander-macro expander _. ._. .._] x))

(defmacro define-expander-macro (expander name args &body body)
  (let expanded-argdef (argument-expand-names 'define-expander-macro args)
    `(set-expander-macro ,expander ',name ',args #'(,expanded-argdef ,@body))))

(defun expander-expand-0 (expander expr)
  (with-temporaries (*macro?*     (expander-pred expander)
                     *macrocall*  (expander-call expander))
    (alet (expander-name expander)
      (? (eq ! *expander-dump?*)
         {(format t "~%; Expander ~A input:~%" !)
          (print expr)
          (format t "~%; Expander ~A output:~%" !)
          (print (%macroexpand expr))}
         (%macroexpand expr)))))

(defun expander-expand (expander expr)
  (| (expander? expander)
     (error "Expander ~A is not defined." (expander-name expander)))
  (funcall (expander-pre expander))
  (prog1 (repeat-while-changes [expander-expand-0 expander _] expr)
    (funcall (expander-post expander))))
