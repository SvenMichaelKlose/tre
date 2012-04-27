;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defun opt-peephole-find-next-tag (x)
  (when x
	(? (atom x.)
	   x
	   (opt-peephole-find-next-tag .x))))

(defun void-assignment? (a)
  (and (%setq? a)
	   (eq .a. ..a.)))

(defun reversed-assignments? (a d)
  (let n d
    (and (%setq? a)
	     (%setq? n)
         .a.
	     (atom .a.)
	     (eq .a. (caddr n))
	     (eq (cadr n) ..a.))))

(defun jump-to-following-tag? (a d)
  (and d (vm-jump? a)
       (? (%%vm-go? a)
          (eq .a. d.)
          (eq ..a. d.))))

;; Remove unreached code or code that does nothing.
(def-opt-peephole-fun opt-peephole-remove-void
  (void-assignment? a)         (opt-peephole-remove-void d)
  (reversed-assignments? a d)  (cons a (opt-peephole-remove-void .d))
  (jump-to-following-tag? a d) (opt-peephole-remove-void d)
  ; Remove code after label until next tag.
  (%%vm-go? a)                 (cons a (opt-peephole-remove-void (opt-peephole-find-next-tag d))))
