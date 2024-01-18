(def-head-predicate %rest)
(def-head-predicate %body)
(def-head-predicate %key)

(fn %rest-or-%body? (x)
  (| (%rest? x)
     (%body? x)))

(fn argument-synonym? (x)
  (| (%rest-or-%body? x)
     (%key? x)))

(fn argument-rest-keyword? (x)
  (in? x '&rest '&body))

;;; The only and only type specifier possible for the beginning.
(fn argument-type-specifier? (x)
  (| (string? x)
     (assoc x *types*)))

(fn typed-argument? (x)
  (& (cons? x)
     (argument-type-specifier? .x.)))

(fn error-argument-missing (fun-name arg-name)
  (error "Argument ~A missing for ~A." arg-name fun-name))

(fn error-too-many-arguments (fun-name argdef args)
  (without-automatic-newline
    (error "Too many arguments ~A to ~A with argument definition ~A."
           args fun-name argdef)))

(fn error-&rest-has-value (fun-name)
  (error "In arguments to ~A: &REST cannot have a value." fun-name))

(fn argdef-get-name (x)
  (? (cons? x)
     x.
     x))

(fn argdef-get-default (x)
  (? (cons? x)
     (? (argument-type-specifier? .x.)
        ..x.
        .x.)
     x))

(fn argdef-get-type (x)
  (& (cons? x)
     (argument-type-specifier? .x.)
     .x.))

(fn argdef-get-value (defs vals)
  (?
    (cons? vals)   vals.
    (cons? defs.)  (cadr defs.)
    defs.))

(fn make-&key-alist (def)
  (with (keys nil
         make-&key-descr
           [when _
             (? (argument-keyword? _.)
                (copy-def-until-&key _)
                (!= _.
                  (push (? (cons? !)
                           (. !. (argdef-get-default !))
                           (. ! !))   ; with itself
                        keys)
                  (make-&key-descr ._)))]
         copy-def-until-&key
           [when _
             (? (eq '&key _.)
                (make-&key-descr ._)
                (. _. (copy-def-until-&key ._)))])
    (values (copy-def-until-&key def)
            (reverse keys))))

;;; Returns expanded arguments as an associative list whose
;;; values are all NIL if APPLY-VALUES? is also NIL.
(fn argument-expand-0 (fun adef vals apply-values? break-on-errors?)
  (with ((argdefs key-args) (make-&key-alist adef)
         num        0
         no-static  nil
         rest-arg   nil
         err
           #'((msg &rest args)
               (? break-on-errors?
                  (error (+ "~L; In argument expansion for ~A:~A: ~A~%"
                            "; Argument definition: ~A~%"
                            "; Given arguments: ~A~%")
                         (package-name (symbol-package fun))
                         (symbol-name fun)
                         (apply #'format nil msg args)
                         adef
                         vals)
                  :error))

         exp-static-assert
           #'((def vals)
               (& no-static
                  (return (err "Static argument definition after ~A."
                               no-static)))
               (& apply-values? (not vals)
                  (return (err "Argument ~A missing." num))))

         exp-static
           #'((def vals)
               (exp-static-assert def vals)
               (. (. (argdef-get-name def.) vals.)
                  (exp-main .def .vals)))

         exp-static-typed
           #'((def vals)
               (exp-static-assert def vals)
               (!= (argdef-get-type def.)
                 (unless (| (& (string? !)
                               (equal vals. !))
                            (type? vals. !))
                   (return (err "\"~A\" expected for argument ~A."
                                (argdef-get-type def.)
                                (argdef-get-name def.)))))
               (. (. (argdef-get-name def.) vals.)
                  (exp-main .def .vals)))

         exp-key
           #'((def vals)
               (let-if k (assoc ($ vals.) key-args :test #'eq)
                 (!= vals
                   (unless .!
                     (return (err "Value of ~A missing." !.)))
                   (rplacd k (. '%key .!.))
                   (exp-main def ..!))
                 (exp-main-non-key def vals)))

         exp-rest
           #'((synonym def vals)
               (= no-static '&rest)
               (= rest-arg (list (. (argdef-get-name .def.)
                                    (. synonym vals))))
               nil)

         exp-optional
           #'((def vals)
               (= no-static '&optional)
               (. (. (argdef-get-name def.)
                     (argdef-get-value def vals))
                  (?
                    (argument-keyword? .def.)
                      (exp-main .def .vals)
                    .def
                      (exp-optional .def .vals)
                    (exp-main .def .vals))))

         exp-optional-rest
           #'((def vals)
               (case def. :test #'eq
                 '&rest     (exp-rest '%rest def vals)
                 '&body     (exp-rest '%body def vals)
                 '&optional (exp-optional .def vals)))

         exp-sub
           #'((def vals)
               (& no-static
                  (return (err "Argument sublist definition after ~A."
                               no-static)))
               (& apply-values?
                  (atom vals.)
                  (return (err "Sublist expected as ~A." num)))
               (nconc (argument-expand-0 fun def. vals.
                                         apply-values?
                                         break-on-errors?)
                      (exp-main .def .vals)))

         exp-check-too-many
           #'((def vals)
               (& (not def) vals
                  (return (err "~A too many argument(s). Maximum is ~A."
                               (length vals) (length argdefs)))))

         exp-main-non-key
           #'((def vals)
               (exp-check-too-many def vals)
               (?
                 (argument-keyword? def.)
                   (exp-optional-rest def vals)
                 (typed-argument? def.)
                   (exp-static-typed def vals)
                 (cons? def.)
                   (exp-sub def vals)
                 (exp-static def vals)))

         exp-main
           #'((def vals)
               (++! num)
               (? (keyword? vals.)
                  (exp-key def vals)
                  (| (exp-check-too-many def vals)
                     (& def
                        (exp-main-non-key def vals))))))

     (!= (exp-main argdefs vals)
       (? (eq ! :error)
          !
          (nconc ! (nconc key-args rest-arg))))))

(fn argument-expand (fun def vals &key (apply-values? t) (break-on-errors? t))
  (!= (argument-expand-0 fun def vals apply-values? break-on-errors?)
    (? (| apply-values?
          (eq ! :error))
       !
       (carlist !))))

(fn argument-expand-names (fun def)
  (argument-expand fun def nil :apply-values? nil))

(fn argument-expand-values (fun def vals &key (break-on-errors? t))
  (@ [? (argument-synonym? _) ._ _]
     (cdrlist (argument-expand fun def vals
                               :break-on-errors? break-on-errors?))))
