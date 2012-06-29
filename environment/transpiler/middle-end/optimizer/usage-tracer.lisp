;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun %setq-on? (x plc)
  (& (%setq? x)
     (eq (%setq-place x) plc)))

(defun opt-peephole-tag-code (tag)
  (member tag *opt-peephole-body* :test #'eq))

(defun opt-peephole-will-be-used-again? (x v)
  (with (traversed-tags nil
         traverse-tag #'((tag v)
                          (!? (opt-peephole-tag-code tag)
                              (unless (member tag traversed-tags :test #'eq)
                                (push tag traversed-tags)
                                (rec .! v))
                              (progn
                                (print *opt-peephole-body*)
                                (print tag)
                                (error "no tag"))))
         rec #'((x v)
                 (with (a x.
                        d .x)
                   (?
	                 (not x)         (~%ret? v)
	                 (atom x)        (error "illegal meta-code: statement expected")
	                 (lambda? a)     (rec d v)
                     (%%vm-go? a)    (traverse-tag .a. v)
                     (%setq-on? a v) (find-tree (%setq-value a) v :test #'eq)
                     (find-tree a v :test #'eq) t
                     (vm-conditional-jump? a) (| (traverse-tag ..a. v) (rec d v))
                     (rec d v)))))
    (| (eq *opt-peephole-funinfo* (transpiler-global-funinfo *current-transpiler*))
       (& (not (~%ret? v))
          (transpiler-defined-variable *current-transpiler* v))
       (funinfo-immutable? *opt-peephole-funinfo* v)
       (rec x v))))

(defun removable-place? (x)
  (& x (atom x)
     (funinfo-in-env? *opt-peephole-funinfo* x)
     (not (eq x (funinfo-lexical *opt-peephole-funinfo*)))
     (not (funinfo-lexical? *opt-peephole-funinfo* x))))

(defun assignment-to-unused-place? (a d)
  (& (%setq? a)
     (removable-place? (%setq-place a))
     (not (opt-peephole-will-be-used-again? d (%setq-place a)))))

(defun assignment-to-unneccessary-temoporary? (a d)
  (& d
     (%setq? a)
	 (%setq? d.)
	 (let-when plc (%setq-place a)
	 (& (eq plc (%setq-value d.))
        (removable-place? plc)
        (not (opt-peephole-will-be-used-again? .d plc))))))
