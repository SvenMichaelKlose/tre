;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun assignment-to-unneccessary-temoporary? (a d)                                                                                                                              
  (& d (%setq? a) (%setq? d.)
     (let-when plc (%setq-place a)
       (& (eq plc (%setq-value d.))
          (not (opt-peephole-will-be-used-again? .d plc))))))

(def-opt-peephole-fun opt-peephole-remove-assignments
  (assignment-to-unneccessary-temoporary? a d)
	(cons `(%setq ,(%setq-place d.) ,(%setq-value a))
	      .d))
