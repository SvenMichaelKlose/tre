(%defmacro defvar (name &optional (init '%%%no-init))
  (print-definition `(defvar ,name))
  (? (not (symbol? name))
     (%error "Symbol expected as variable name."))
  `(%defvar ,name ,(? (eq '%%%no-init init)
                      `',init
                      init)))

(%defmacro var (name &optional (init nil))
  `(defvar ,name ,init))

(defvar *constants* nil)

(%defmacro defconstant (name &optional (init nil))
  (print-definition `(defconstant ,name))
  `(progn
     (defvar ,name ,init)
     (setq *constants* (. (. ',name ',init) *constants*))))
