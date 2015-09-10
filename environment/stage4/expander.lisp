; tré – Copyright (c) 2006–2009,2011–2015 Sven Michael Klose <pixel@copei.de>

(defvar *expanders* nil)

(defstruct expander
  macros
  argdefs
  pred
  call
  pre
  post
  lookup
  user) ; For external use.

(defun expander-get (name)
  (cdr (assoc name *expanders* :test #'eq)))

(defun expander-macro-function (expander macro-name)
  (href (expander-macros expander) macro-name))

(defun expander-macro-argdef (expander macro-name)
  (href (expander-argdefs expander) macro-name))

(defun (= expander-macro-function) (new-function expander macro-name)
  (= (href (expander-macros expander) macro-name) new-function))

(defun define-expander (expander-name &key (pre nil) (post nil) (pred nil) (call nil))
  (format t "Making expander ~A.~%" expander-name)
  (aprog1 (make-expander :macros (make-hash-table :test #'eq)
                         :argdefs (make-hash-table :test #'eq)
                         :pred pred
                         :call call
                         :pre (| pre #'(nil))
                         :post (| post #'(nil)))
    (acons! expander-name ! *expanders*)
    (| pred
       (= (expander-pred !) [& (cons? _)
                               (symbol? _.)
	                           (expander-macro-function ! _.)]))
    (| call
       (= (expander-call !) [apply (expander-macro-function ! _.) (argument-expand-values 'expander-call (expander-macro-argdef ! _.) ._)]))
    (= (expander-lookup !)
       #'((expander name)
           (href (expander-macros expander) name)))))

(defun set-expander-macro (expander-name name argdef fun &key (may-redefine? nil))
  (& (not may-redefine?)
     (expander-has-macro? expander-name name)
     (warn "Macro ~A already defined." name))
  (alet (expander-get expander-name)
    (= (href (expander-macros !) name) fun)
    (= (href (expander-argdefs !) name) argdef)))

(defun set-expander-macros (expander-name lst)
  (map [set-expander-macro expander-name _. ._. .._] lst))

(defmacro define-expander-macro (expander-name name args &body body)
  (| (atom expander-name)
     (error "Atom expected as expander-name instead of ~A." expander-name))
  (| (atom name)
     (error "Atom expected as macro-name instead of ~A for expander ~A." name expander-name))
  (let expanded-argdef (argument-expand-names 'define-expander-macro args)
    (with-gensym g
      `(progn
         (& (expander-has-macro? ',expander-name ',name)
            (error ,(format nil "Redefinition of macro ~A in expander ~A." name expander-name)))
           (defun ,g ,expanded-argdef ,@body)
           (alet (expander-get ',expander-name)
             (alet (expander-macros !)
               (= (href ! ',name) #',g))
             (alet (expander-argdefs !)
               (= (href ! ',name) `,args)))))))

(defun expander-expand-once (expander-name x)
  (alet (expander-get expander-name)
    (| (expander? !)
       (error "Expander ~A is not defined." (symbol-name expander-name)))
    (with-temporaries (*macro?*     (expander-pred !)
                       *macrocall*  (expander-call !))
      (%macroexpand x))))

(defun expander-expand (expander-name expr)
  (alet (expander-get expander-name)
    (| (expander? !)
       (error "Expander ~A is not defined." (symbol-name expander-name)))
    (funcall (expander-pre !))
    (prog1
      (repeat-while-changes [expander-expand-once expander-name _] expr)
      (funcall (expander-post !)))))

(defun expander-has-macro? (expander-name macro-name)
  (href (expander-macros (expander-get expander-name)) macro-name))

(defun expander-macro-names (expander-name)
  (hashkeys (expander-macros (expander-get expander-name))))
