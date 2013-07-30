;;;;; tré – Copyright (c) 2006–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defvar *expanders* nil)

(defstruct expander
  macros
  pred
  call
  pre
  post
  lookup
  user) ; For external use.

(defun expander-get (name)
  (cdr (assoc name *expanders* :test #'eq)))

(defvar *expander-print* nil)

(defun expander-macro-function (expander-name macro-name)
  (href (expander-macros expander-name) macro-name))

(defun (= expander-macro-function) (new-function expander-name macro-name)
  (= (href (expander-macros expander-name) macro-name) new-function))

(defun define-expander (expander-name &key (pre nil) (post nil) (pred nil) (call nil))
  (aprog1 (make-expander :macros (make-hash-table :test #'eq)
                         :pred pred
                         :call call
                         :pre (| pre #'(nil))
                         :post (| post #'(nil)))
    (acons! expander-name ! *expanders*)
    (| pred (= (expander-pred !) (lx (!) [& (symbol? _.)
	                                        (symbol-name _.)
	                                        (expander-macro-function ,! _.)])))
    (| call (= (expander-call !) (lx (!) [(& *expander-print* (print _))
                                          (apply (expander-macro-function ,! _.) ._)])))
    (= (expander-lookup !)
       #'((expander name)
           (href (expander-macros expander) name)))))

(defun set-expander-macro (expander-name name fun &key (may-redefine? nil))
  (& (not may-redefine?)
     (expander-has-macro? expander-name name)
     (warn "Macro ~A already defined." name))
  (= (href (expander-macros (expander-get expander-name)) name) fun))

(defun set-expander-macros (expander-name lst)
  (map [set-expander-macro expander-name _. ._] lst))

(defmacro define-expander-macro (expander-name name args &body body)
  (| (atom expander-name)
     (error "Atom expected as expander-name instead of ~A." expander-name))
  (| (atom name)
     (error "Atom expected as macro-name instead of ~A for expander ~A." name expander-name))
  (with-gensym g
    `(progn
       (& (expander-has-macro? ',expander-name ',name)
          (error "Redefinition of macro ~A in expander ~A." ',name ',expander-name))
       (defun ,g ,args ,@body)
       (alet (expander-macros (expander-get ',expander-name))
         (= (href ! ',name) #',g)))))

(defun expander-expand-once (expander-name x)
  (alet (expander-get expander-name)
    (| (expander? !) (error "Expander ~A is not defined." (symbol-name expander-name)))
    (with-temporaries (*macrop-diversion* (expander-pred !)
                       *macrocall-diversion* (expander-call !))
      (%macroexpand x))))

(defun expander-expand (expander-name expr)
  (alet (expander-get expander-name)
    (| (expander? !) (error "Expander ~A is not defined." (symbol-name expander-name)))
    (funcall (expander-pre !))
    (prog1
      (repeat-while-changes [expander-expand-once expander-name _] expr)
      (funcall (expander-post !)))))

(defun expander-has-macro? (expander-name macro-name)
  (href (expander-macros (expander-get expander-name)) macro-name))

(defun expander-macro-names (expander-name)
  (hashkeys (expander-macros (expander-get expander-name))))
