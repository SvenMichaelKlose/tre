;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun inverted-%%go (x)
  (?
    (eq x '%%go-nil)     '%%go-not-nil
    (eq x '%%go-not-nil) '%%go-nil
    (error "Jump expected instead of ~A." x)))

(defun jumps-to-tag (x)
  (count-if [& (vm-jump? _)
               (== x (%%go-tag _))]
            *body*))

(def-opt-peephole-fun opt-peephole-invert-jumps
#|
  (& (%setq? a)
     (~%ret? (%setq-place a))
     (| (not (%setq-value a))
        (t? (%setq-value a)))
     (%%go-cond? d.)
     (awhen (member (%%go-tag d.) *body*)
       (& (? (%setq-value a)
             (%%go-not-nil? .!.)
             (%%go-nil? .!.))
          (not (opt-peephole-will-be-used-again? (member (%%go-tag .!.) *body*) '~%ret)))))
    `((%%go ,(%%go-tag (cadr (member (%%go-tag d.) *body*))))
      ,@(opt-peephole-invert-jumps .d))
  (& (%%go-nil?             a)
     (equal                 d. '(%setq ~%ret nil))
     (%%go?                .d.)
     (number?             ..d.)
     (== (%%go-tag a)     ..d.)
     (equal              ...d. '(%setq ~%ret t))
     (number?           ....d.)
     (== (%%go-tag .d.) ....d.)
     (%%go-cond?       .....d.)
     (with (tag1   ..d.
            tag2 ....d.)
       (& (== 1 (jumps-to-tag tag1))
       (& (== 1 (jumps-to-tag tag2))))))
    `((,(inverted-%%go (car .....d.)) ,(%%go-tag .....d.) ~%ret)
      ,@(opt-peephole-invert-jumps ......d))
|#
  (& (%%go-nil?   a)
     (%%go?      d.)
     (number?   .d.)
     (== (%%go-tag a) .d.))
    `((%%go-not-nil ,(%%go-tag d.) ~%ret)
      ,@(opt-peephole-invert-jumps .d))
  (& (%%go-not-nil?  a)
     (%%go?         d.)
     (number?   .d.)
     (== (%%go-tag a) .d.))
    `((%%go-nil ,(%%go-tag d.) ~%ret)
      ,@(opt-peephole-invert-jumps .d)))
