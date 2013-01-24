;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun find-next-tag (x)
  (? (atom x.)
     x
     (find-next-tag .x)))

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
  (& d (vm-jump? a)
     (? (%%go? a)
        (eq .a. d.)
        (eq ..a. d.))))

(def-opt-peephole-fun opt-peephole-remove-void
  (assignment-to-self? a)      (opt-peephole-remove-void d)
  (reversed-assignments? a d)  (cons a (opt-peephole-remove-void .d))
  (jump-to-following-tag? a d) (opt-peephole-remove-void d)
  ; Remove code after label until next tag.
  (%%go? a)                    (cons a (opt-peephole-remove-void (find-next-tag d))))
