;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun tag-code (tag)
  (| (member-if [& (number? _) (== _ tag)]
                *body*)
     (error "tag ~A not found in body ~A" tag *body*)))

(defun removable-place? (x)
  (alet *funinfo*
    (& (funinfo-var? ! x)
       (not (eq x (funinfo-lexical !))
            (funinfo-lexical? ! x)
            (funinfo-immutable? ! x)
            (unless (funinfo-parent !)
              (| (transpiler-defined-function *transpiler* x)
                 (transpiler-defined-variable *transpiler* x)))))))

(defun opt-peephole-will-be-used-again? (x v)
   (with (traversed-tags nil
          traversed-tag?
            [member _ traversed-tags :test #'number==]
          traverse-tag
            [unless (traversed-tag? _)
              (push _ traversed-tags)
              (traverse-statements (tag-code _))]
          traverse-statements
            [? (not _)
               (& (funinfo-parent *funinfo*)
                  (~%ret? v))
               (with-cons a d _
                 (?
                   (%setq? a)       (with (place (%setq-place a)
                                           value (%setq-value a))
                                      (? (eq v place value)
                                         (traverse-statements d)
                                         (| (find-tree v value :test #'eq)
                                            (unless (eq v place)
                                              (traverse-statements d)))))
                   (%%vm-go? a)     (traverse-tag .a.)
                   (%%vm-go-nil? a) (| (eq v .a.)
                                       (traverse-tag ..a.)
                                       (traverse-statements d))
                   (number? a)      (traverse-statements d)
                   (progn
                     (print _)
                     (error "illegal metacode statement ~A" _))))])
    (| (not (removable-place? v))
       (traverse-statements x))))
