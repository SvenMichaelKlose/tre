;;;;;;;;;;;;;;;;;;;;;;;;
;;; WORK IN PROGRESS ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

(var *types* nil)

(defstruct %type
  name
  fun
  (parent nil))

(fn find-type (name)
  (assoc-value name *types*))

(macro deftype (name args &key (parent nil)
                          &body body)
  (print-definition `(deftype ,name ,args))
;  (& (assoc name *types*)
;     (error "Type ~A is already defined." name))
  (& parent
     (| (find-type parent)
        (error "Parent type ~A is not defined." parent)))
  (acons! name
          (make-%type :name   name
                     :parent parent
                     :fun    (eval `#'(,args
                                        ,@body)))
          *types*)
  `(acons! ',name
          (make-%type :name   ',name
                     :parent ',parent
                     :fun    #'(,args
                                 ,@body))
          *types*))

(fn type? (o x)
  (when x
    (? (cons? x)
       (case x.
         'and        (every [type? o _] .x)
         'or         (some  [type? o _] .x)
         'satisfies  (funcall (| (symbol-function .x.)
                                 (error "~A is not a predicate for SATISFIES."
                                        .x.))
                              o)
         (!? (find-type x.)
             (apply (%type-fun !) .x)
             (error "Unknown type specifier symbol ~A." x.)))
       (? (string? x)
          (equal o x)
          (type? o (funcall (| (%type-fun (assoc-value x *types*))
                               (error "No typespecifier for ~A." x))))))))

(deftype null ()
  '(satisfies not))

(progn
  ,@(@ [`(deftype ,_ () '(satisfies ,($ _ '?)))]
       '(symbol cons list
         number float integer character
         array string hash-table)))

(| (& (type? nil 'null)
      (type? 'a 'symbol)
      (type? (. t t) 'cons)
      (type? (. t t) 'list)
      (type? 1.6128 'number)
      (type? 1 'integer)
      (type? #\c 'character)
      (type? (make-array 3) 'array)
      (type? "foo" 'string))
   (error "TYPE? error"))
