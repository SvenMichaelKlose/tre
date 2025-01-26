(fn tag-code (tag)
  "Return expressions after tag in *BODY*."
  (| (member tag *body*)
     (funinfo-error "Internal compiler error: Tag ~A not found in body ~A."
                    tag *body*)))

(fn removable-place? (x)
  (!= *funinfo*
    (& (funinfo-parent !)
       (funinfo-var? ! x)
       (not (eq x (funinfo-scope !))
            (funinfo-scoped-var? ! x)))))

(fn will-be-used-again? (x v)
   (with (traversed-tags  nil
          traversed-tag?  [member _ traversed-tags :test #'==]
          traverse-tag    [unless (traversed-tag? _)
                            (push _ traversed-tags)
                            (traverse-statements (tag-code _))]
          traverse-statements
            [? (not _)
               (& (funinfo-parent *funinfo*)
                  (~%ret? v))
               (with-cons a d _
                 (?
                   (| (number? a)
                      (%comment? a)
                      (named-lambda? a))
                     (traverse-statements d)
                   (%=? a)
                     (with-%= place value a
                       (| (tree-find v value :test #'eq)
                          (unless (eq v place)
                            (| (tree-find v place :test #'eq)
                               (traverse-statements d)))))
                   (%go? a)
                     (traverse-tag .a.)
                   (conditional-%go? a)
                     (| (eq v ..a.)
                        (traverse-tag .a.)
                        (traverse-statements d))
                   (progn
                     (print _)
                     (funinfo-error "Illegal metacode statement ~A." _))))])
    (| (not (removable-place? v))
       (traverse-statements x))))
