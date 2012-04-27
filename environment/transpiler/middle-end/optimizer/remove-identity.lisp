;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defun assignment-of-identity? (a)
  (and (%setq? a)
	   (identity? ..a.)))

(def-opt-peephole-fun opt-peephole-remove-identity
  (assignment-of-identity? a)
    (cons `(%setq ,.a. ,(cadr ..a.))
	      (opt-peephole-remove-identity d)))
