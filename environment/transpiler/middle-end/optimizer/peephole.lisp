; tré – Copyright (c) 2008–2016 Sven Michael Klose <pixel@copei.de>

(defun assignment-to-self? (x)
  (& (%=? x)
     (eq .x. ..x.)))

(defun reversed-assignments? (a d)
  (let n d.
    (& (%=? a)
	   (%=? n)
       .a. (atom .a.)
	   (eq .a. ..n.)
	   (eq .n. ..a.))))

(defun jump-to-following-tag? (a d)
  (& d
     (vm-jump? a)
     (eql (%%go-tag a) d.)))

(defun unused-atom-or-functional? (x)
  (& (%=? x)
     (not .x.)
     (atomic-or-functional? ..x.)))

(defun %=-identity? (x)
  (& (%=? x)
     (identity? ..x.)))

(define-optimizer opt-peephole
  (reversed-assignments? a d)        (. a (opt-peephole .d))
  (| (jump-to-following-tag? a d)
     (unused-atom-or-functional? a)
     (assignment-to-self? a))        (opt-peephole d)
  (%%go? a)                          (. a (opt-peephole (member-if #'atom d)))
  (%=-identity? a)                   (. `(%= ,.a. ,(cadr ..a.))
                                        (opt-peephole d)))
