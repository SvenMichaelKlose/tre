; tré – Copyright (c) 2010–2015 Sven Michael Klose <pixel@hugbox.org>

(defun sloppy-equal (x needle)
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

(defun sloppy-tree-equal (x needle)
  (| (sloppy-equal x needle)
     (& (cons? x)
        (| (sloppy-tree-equal x. needle)
           (sloppy-tree-equal .x needle)))))

(defun dump-pass? (name x)
  (& *transpiler*
     (| (!? (dump-passes?)
            (| (t? !)
               (member name (ensure-list !))))
        (!? (dump-selector)
            (sloppy-tree-equal x !)))))

(defun dump-pass (end pass x)
  (& (| (dump-pass? pass x)
        (dump-pass? end x))
     (? (equal x (last-pass-result))
        (format t "; Pass ~A outputs no difference to previous dump.~%" pass)
        (format t (+ "~L; **** Dump of pass ~A:~%"
                     "~A"
                     "~L; **** End of ~A.~%")
                  pass x pass)))
  x)

(defun transpiler-pass (p list-of-exprs)
  (with-global-funinfo (funcall p list-of-exprs)))

(defun transpiler-end (name passes list-of-lists-of-exprs)
  (| (enabled-end? name)
     (return list-of-lists-of-exprs))
  (& (| (t? (dump-passes?))
        (dump-pass? name list-of-lists-of-exprs))
     (format t "~%~L; #### Compiler end ~A~%~%" name))
  (@ #'((list-of-exprs)
         (& list-of-exprs
            (with (outpass  (cdr (assoc name (output-passes)))
                   out      nil)
              (@ (p passes (? outpass out list-of-exprs))
                (when (enabled-pass? p.)
                  (= list-of-exprs (dump-pass name p. (transpiler-pass .p list-of-exprs)))
                  (= (last-pass-result) list-of-exprs)
                  (& (eq p. outpass)
                     (= out list-of-exprs)))))))
     list-of-lists-of-exprs))

(defmacro define-transpiler-end (name &rest name-function-pairs)
  (alet (group name-function-pairs 2)
    `(defun ,name (list-of-lists-of-exprs)
       (transpiler-end ,(make-keyword name)
                       (list ,@(@ [`(. ,@_)] ; [. '. _]
                                  (pairlist (@ #'make-keyword (carlist !))
                                            (cdrlist !))))
                       list-of-lists-of-exprs))))
