(var *type-predicates*
  '((nil        . not)
    (cons       . cons?)
    (list       . list?)
    (atom       . atom)
    (symbol     . symbol?)
    (function   . function?)
    (number     . number?)
    (integer    . number?)
    (float      . number?)
    (character  . character?)
    (array      . array?)
    (string     . string?)
    (hash-table . hash-table?)))

(fn %declare-type-predicate (typ)
  (assoc-value typ *type-predicates*))

(fn %declare-statement-type-predicate (typ x)
  `(,(| (%declare-type-predicate typ)
        ($ typ '?))
    ,x))

(fn %declare-statement-type-1 (typ x)
  (| (symbol? x)
     (error "Symbol expected but got ~A to declare as of type ~A." x typ))
  `(unless (| ,@(@ [%declare-statement-type-predicate _ x]
                   (ensure-list typ)))
     (error "~A is not of type ~A. Object: ~A." ,(symbol-name x) (quote ,typ) ,x)))

(fn %declare-statement-type (x)
  (| (<= 2 (length x))
     (error "Expected type and one or more variables, but got only ~A." x))
  `(progn
     ,@(@ [%declare-statement-type-1 x. _] .x)))

(var *declare-statement-classes*
  '((type . %declare-statement-type)))

(fn %declare-statement (x)
  (funcall (symbol-function
               (| (assoc-value x. *declare-statement-classes*)
                  (error (+ "Unknown declaration class ~A."
                            " Choose one of ~A instead.")
                         x. (carlist *declare-statement-classes*))))
           .x))

(defmacro declare (&rest x)
  (| x (error "Arguments expected."))
  (!= (@ #'%declare-statement (ensure-tree x))
    (when *assert?*
      `(progn
         ,@!))))
