(fn sloppy-equal (x needle)
  (& (atom x)
     (atom needle)
     (return (eql x needle)))
  (& (cons? x)
     (not needle)
     (return t))
  (& (cons? x)
     (cons? needle)
     (equal x. needle.)
     (sloppy-equal .x .needle)))

(fn sloppy-tree-equal (x needle)
  (| (sloppy-equal x needle)
     (& (cons? x)
        (| (sloppy-tree-equal x. needle)
           (sloppy-tree-equal .x needle)))))

(fn dump-pass? (name x)
   (| (!? (dump-passes?)
          (| (eq t !)
             (member name (ensure-list !))))
      (!? (dump-selector)
          (sloppy-tree-equal x !))))

(fn dump-pass (end pass x)
  (& (| (dump-pass? pass x)
        (dump-pass? end x))
     (? (equal x (last-pass-result))
        (format t ";      …no difference to previous dump.~%" pass)
        (progn
          (format t "; >>>> Dump of pass ~A:~%" (symbol-name pass))
          (print x)
          (format t "~L; <<<< End of pass ~A.~%" (symbol-name pass)))))
  x)

(fn transpiler-pass (p list-of-exprs)
  (with-global-funinfo (~> p list-of-exprs)))

(fn transpiler-end (name passes list-of-exprs)
  (| (enabled-end? name)
     (return list-of-exprs))
  (& (dump-pass? name list-of-exprs)
     (format t "~%; ######## Compiler end ~A~%" (symbol-name name)))
  (& list-of-exprs
     (with (outpass  (cdr (assoc name (output-passes)))
            out      nil)
       (@ (p passes (? outpass out list-of-exprs))
         (? (enabled-pass? p.)
            (progn
              (= list-of-exprs (dump-pass name p.
                                          (transpiler-pass .p list-of-exprs)))
              (= (last-pass-result) list-of-exprs)
              (& (eq p. outpass)
                 (= out list-of-exprs))))))))

(defmacro define-transpiler-end (name &rest name-function-pairs)
  (!= (group name-function-pairs 2)
    `(fn ,(make-symbol (symbol-name name)) (list-of-exprs)
       (transpiler-end ,name
                       (… ,@(@ [`(. ,@_)]
                               (pairlist (@ #'make-keyword (carlist !))
                                         (cdrlist !))))
                       list-of-exprs))))
