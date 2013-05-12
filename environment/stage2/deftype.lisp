;;;;; tré – 2013 Sven Michael Klose <pixel@copei.de>

(defvar *types*    nil)

(defmacro deftype (name super)
  (print-definition `(deftype ,name ,super))
  (& (assoc name *types* :test #'eq)
     (error "Type ~A is already defined." (symbol-name name)))
  (& super
     (| (assoc super *types* :test #'eq)
        (error "Supertype ~A is not defined." (symbol-name super))))
  (acons! name super *types*)
  nil)

(deftype t nil)
(deftype atom t)
(deftype cons t)
(deftype array atom)
