; tré – Copyright (c) 2006–2009,2011–2015 Sven Michael Klose <pixel@copei.de>

(defstruct expander
  name
  macros
  argdefs
  pred
  call
  pre
  post
  lookup
  user) ; For external use.

(defun expander-macro-function (expander macro-name)
  (href (expander-macros expander) macro-name))

(defun expander-macro-argdef (expander macro-name)
  (href (expander-argdefs expander) macro-name))

(defun (= expander-macro-function) (new-function expander macro-name)
  (= (href (expander-macros expander) macro-name) new-function))

(defun expander-has-macro? (expander macro-name)
  (href (expander-macros expander) macro-name))

(defun define-expander (expander-name &key (pre nil) (post nil) (pred nil) (call nil))
  (format t "Making expander ~A.~%" expander-name)
  (aprog1 (make-expander :name expander-name
                         :macros (make-hash-table :test #'eq)
                         :argdefs (make-hash-table :test #'eq)
                         :pred pred
                         :call call
                         :pre (| pre #'(nil))
                         :post (| post #'(nil)))
    (| pred
       (= (expander-pred !) [& (cons? _)
                               (symbol? _.)
	                           (expander-macro-function ! _.)]))
    (| call
       (= (expander-call !) [apply (expander-macro-function ! _.)
                                   (argument-expand-values _. (expander-macro-argdef ! _.) ._)]))
    (= (expander-lookup !)
       #'((expander name)
           (href (expander-macros expander) name)))))

(defun set-expander-macro (expander name argdef fun &key (may-redefine? nil))
  (& (not may-redefine?)
     (expander-has-macro? expander name)
     (warn "Macro ~A already defined for expander ~A." name (expander-name expander)))
  (= (href (expander-macros expander) name) fun)
  (= (href (expander-argdefs expander) name) argdef))

(defun set-expander-macros (expander lst)
  (map [set-expander-macro expander _. ._. .._] lst))

(defmacro define-expander-macro (expander-name name args &body body)
  (| (atom name)
     (error "Atom expected as macro-name instead of ~A for expander ~A." name expander-name))
  (let expanded-argdef (argument-expand-names 'define-expander-macro args)
    (with-gensym (g expander)
      `(let ,expander ,expander-name
         (& (expander-has-macro? ,expander ',name)
            (warn ,(format nil "Redefinition of macro ~A for expander ~A." name expander-name)))
         (defun ,g ,expanded-argdef ,@body)
         (= (href (expander-macros ,expander) ',name) #',g)
         (= (href (expander-argdefs ,expander) ',name) `,args)))))

(defun expander-expand (expander expr)
  (| (expander? expander)
     (error "Expander ~A is not defined." (expander-name expander)))
  (funcall (expander-pre expander))
  (prog1
    (repeat-while-changes [with-temporaries (*macro?*     (expander-pred expander)
                                             *macrocall*  (expander-call expander))
                             (%macroexpand _)]
                          expr)
    (funcall (expander-post expander))))

(defun expander-macro-names (expander)
  (hashkeys (expander-macros expander)))
