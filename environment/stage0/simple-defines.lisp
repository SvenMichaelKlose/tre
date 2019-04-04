(%defmacro defvar (name &optional (init '%%%no-init))
  (print-definition `(var ,name))
  (? (not (symbol? name))
     (%error "Symbol expected as variable name."))
  `(%defvar ,name ,(? (eq '%%%no-init init)
                      `',init
                      init)))

(%defmacro var (name &optional (init nil))
  `(defvar ,name ,init))

(var *constants* nil)

(%defmacro defconstant (name &optional (init nil))
  (print-definition `(defconstant ,name))
  `(progn
     (var ,name ,init)
     (setq *constants* (. (. ',name ',init) *constants*))))

(%defmacro const (name &optional (init nil))
  `(defconstant ,name ,init))
