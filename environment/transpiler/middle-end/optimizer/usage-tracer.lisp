;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun tag-code (tag)
  (member-if [& (number? _) (== _ tag)] *opt-peephole-body*))

(defun removable-place? (x)
  (alet *opt-peephole-funinfo*
    (& (funinfo-in-env? ! x)
       (not (eq x (funinfo-lexical !))
            (funinfo-lexical? ! x)
            (funinfo-immutable? ! x)
            (unless (funinfo-parent !)
              (| (transpiler-defined-function *current-transpiler* x)
                 (transpiler-defined-variable *current-transpiler* x)))))))

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
               (& (funinfo-parent *opt-peephole-funinfo*)
                  (~%ret? v))
               (with-cons a d _
                 (?
                   (%setq? a)       (with (place (%setq-place a)
                                           value (%setq-value a))
                                      (? (eq v place value)
                                         (traverse-statements d)
                                         (| (find-tree value v :test #'eq)
                                            (unless (eq v place)
                                              (traverse-statements d)))))
                   (%%vm-go? a)     (traverse-tag .a.)
                   (%%vm-go-nil? a) (| (eq v .a.)
                                       (traverse-tag ..a.)
                                       (traverse-statements d))
                   (number? a)      (unless (traversed-tag? a)
                                      (traverse-statements d))
                   (progn
                     (print _)
                     (error "illegal metacode statement ~A" _))))])
    (| (not (removable-place? v))
       (traverse-statements x))))
