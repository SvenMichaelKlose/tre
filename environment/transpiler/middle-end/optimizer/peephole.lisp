;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun assignment-to-self? (a)
  (& (%setq? a)
     (eq .a. ..a.)))

(defun reversed-assignments? (a d)
  (let n d.
    (& (%setq? a)
	   (%setq? n)
       .a. (atom .a.)
	   (eq .a. ..n.
	   (eq .n. ..a.)))))

(defun jump-to-following-tag? (a d)
  (& d
     (vm-jump? a)
     (eql (%%go-tag a) d.)))

(defun unused-atom-or-functional? (a d)
  (& (%setq? a)
     (not (%setq-place a))
     (atomic-or-functional? (%setq-value a))))

(define-optimizer opt-peephole
  (reversed-assignments? a d)          (cons a (opt-peephole .d))
  (| (jump-to-following-tag? a d)
     (unused-atom-or-functional? a d)
     (assignment-to-self? a))          (opt-peephole d)
  (%%go? a)                            (cons a (opt-peephole (member-if #'atom d))))
