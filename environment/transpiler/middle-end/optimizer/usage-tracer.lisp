(defun tag-code (tag)
  (| (member-if [& (number? _)
                   (== _ tag)]
                *body*)
     (funinfo-error "Internal compiler error: Tag ~A not found in body ~A." tag *body*)))

(defun removable-place? (x)
  (alet *funinfo*
    (& (| (funinfo-parent !)
          (eq '~%ret x)
          (not (defined-variable x)
               (literal? x)))
       (funinfo-var? ! x)
       (not (eq x (funinfo-scope !))
            (funinfo-scoped-var? ! x)))))

(defun will-be-used-again? (x v)
   (with (traversed-tags nil
          traversed-tag? [member _ traversed-tags :test #'==]
          traverse-tag   [unless (traversed-tag? _)
                           (push _ traversed-tags)
                           (traverse-statements (tag-code _))]
          traverse-statements
            [? (not _)
               (& (funinfo-parent *funinfo*)
                  (~%ret? v))
               (with-cons a d _
                 (?
                   (%=? a)        (with-%= place value a
                                    (| (tree-find v value :test #'eq)
                                       (& (%slot-value? place)
                                          (tree-find v place :test #'eq))
                                       (unless (eq v place)
                                         (traverse-statements d))))
                   (%%go? a)      (traverse-tag .a.)
                   (%%go-cond? a) (| (eq v ..a.)
                                     (traverse-tag .a.)
                                     (traverse-statements d))
                   (| (number? a)
                      (%%comment? a)
                      (named-lambda? a))
                                  (traverse-statements d)
                   {(print _)
                    (funinfo-error "Illegal metacode statement ~A." _)}))])
    (| (not (removable-place? v))
       (traverse-statements x))))
