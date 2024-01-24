;;;;;;;;;;;;;;;;;;;;;;;
;;; WORK IN PROGRSS ;;;
;;;;;;;;;;;;;;;;;;;;;;;

;;;; Function overloading

;;; Type tree
;;;
;;; All argument definitions of an overloaded function are merged into a n-way
;;; tree, the root starting with a list of all first arguments and their types.
;;; Each item leads to a new list each for the second argument and so on until
;;; the mathing function is found.  Each list is sorted by the sub-types first.
;;; Each item of that list a cons with the CAR containing the type specifier
;;; or type predicate and the list of the next level or the actual function to
;;; call.  Lets take tree argument definitions and the resulting tree:
;;;
;;; #'fun-a: ((d directory) (name string) flags)
;;; #'fun-b: ((f file) (name string) (flags integer))
;;; #'fun-c: ((f file) (name string))
;;;
;;; Tree: (list (. 'directory
;;;                (list (. 'string #fun-a)))
;;;             (. 'file
;;;                (list (. 'string
;;;                         (list (. 'integer #'fun-b)
;;;                               (. nil #'fun-c))))))
;;;
;;; Unless argument expansion takes place alongside this look-up procedure all
;;; argument definitions must be equal except for their type specifiers.
;;; That has the advantage that only a simple, typeless ARGUMENT-EXPAND-VALUES
;;; has to be performed in advance, which we already have.
;;;
;;; Being that restrictive is not really what we want but we'll go for it to
;;; have a working base which is easier to implement and goes well with the
;;; ANSI Common Lisp standard.

(fn subtype-of? (a b)
  (with (err [error "Type specifier expected instead of ~A." _]
         f   [!? (%type-parent (find-type _))
                 (| (equal a _)
                    (f !))])
     (| (find-type a) (err a))
     (| (find-type b) (err b))
     (f a)))

(fn add-overload (fun expanded-types &optional (typelist nil))
  "Add result of ARGUMENT-EXPAND-TYPES to typed argument tree."
  (unless expanded-types
    (return fun))
  (!? (find-if [equal expanded-types. _.]
               typelist)
      (progn
        (| .! (error "Cannot continue with ~A on ~A." expanded-types !))
        (add-overload fun .expanded-types .!)
        typelist)
      (!= (. expanded-types. (add-overload fun .expanded-types))
         (? typelist
            (sort (. ! typelist) :test #'((a b) (subtype-of? a. b.)))
            (list !)))))

(print '(add-overload 'bar '(string integer)))
(!? (add-overload 'bar '(string integer))
    (unless (equal ! (list (. 'string (list (. 'integer 'bar)))))
      (error "ADD-OVERLOAD -> ~A" !)))

(print '(add-overload 'bar '(string character)))
(!? (add-overload 'bar '(string integer)
                  (add-overload 'fnord '(string character)))
    (unless (equal ! (list (. 'string 
                              (list (. 'integer 'bar)
                                    (. 'character 'fnord)))))
      (error "ADD-OVERLOAD -> ~A" !)))

(print '(add-overload 'bar '(string cons integer)))
(!? (add-overload 'bar '(string cons integer)
                  (add-overload 'fnord '(string number number)))
    (unless (equal ! (list (. 'string 
                              (list (. 'cons (list (. 'integer 'bar)))
                                    (. 'number (list (. 'number 'fnord)))))))
      (error "ADD-OVERLOAD -> ~A" !)))

(fn find-closest-type (type typelist))

(fn dispatch-overload (expanded-types &optional (typelist nil))
  "Find function of closest matching overload."
  (!? (find-closest-type expanded-types. typelist)
      (? (cons? .!)
         (dispatch-overload .expanded-types .!)
         .!)))

(var *overloads* (make-hash-table :test #'eq))

(fn add-method-overload (fun argdef)
  (= (href *overloads* fun)
     (add-overload fun (argument-expand-names 'add-method-overload argdef))))

;; Call best fitting method.
(fn apply-typed (f a v))

; Compiled version of APPLY-TYPED.
(fn gen-method-dispatcher (f a v))
