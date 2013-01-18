;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun assignment-to-symbol? (x)
  (& (%setq? x)
     (%setq-place x)
     (atom x)))

; XXX make new predicate
(def-opt-peephole-fun opt-peephole-rename-temporaries
  (& (assignment-to-symbol? a)
     (%setq? d.)
     (with (plc (%setq-place a)
            val (%setq-value d.))
       (& (not (in? plc '~%ret '~%tmp))
          (cons? val)
          (removable-place? plc)
          (| (eq (%setq-place d.) plc)
             (not (opt-peephole-will-be-used-again? .d plc))))))
    (with (plc (%setq-place a)
           val (%setq-value d.)
           fi *opt-peephole-funinfo*)
      (funinfo-vars-adjoin fi '~%tmp)
      `((%setq ~%tmp ,(%setq-value a))
        (%setq ,(%setq-place d.) ,(replace-tree plc '~%tmp val :test #'eq))
        ,@.d)))
