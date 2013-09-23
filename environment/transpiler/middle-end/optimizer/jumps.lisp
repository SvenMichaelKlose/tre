;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun inverted-%%go (x)
  (case x :test #'eq
    '%%go-nil      '%%go-not-nil
    '%%go-not-nil  '%%go-nil
    (error "Jump expected instead of ~A." x)))

(defun jumps-to-tag (x)
  (count-if [& (vm-jump? _)
               (== x (%%go-tag _))]
            *body*))

(defun constant-jump? (x constant)
  (| (? constant
        (%%go-not-nil? x)
        (%%go-nil? x))
     (%%go? x)))

(defun target-tag (x constant)
  (?
    (not x)                      nil
    (number? x.)                 (target-tag .x constant)
    (constant-jump? x. constant) (| (target-tag (member (%%go-tag x.) *body*) constant)
                                    (%%go-tag x.))))

(defun t|nil? (x)
  (| (not x)
     (t? x)))

(define-optimizer optimize-jumps
  (& (%setq? a)
     (~%ret? (%setq-place a))
     (t|nil? (%setq-value a))
     (!? (target-tag d (%setq-value a))
         (not (opt-peephole-will-be-used-again? (member ! *body*) '~%ret))))
    (cons `(%%go ,(target-tag d (%setq-value a)))
          (optimize-jumps d))
  (& (%setq? a)
     (~%ret? (%setq-place a))
     (t|nil? (%setq-value a))
     (? (%setq-value a)
        (%%go-nil? d.)
        (%%go-not-nil? d.)))
     (cons a (optimize-jumps .d))
  (& (%%go-cond? a)
     (%%go? d.)
     (number? .d.)
     (== (%%go-tag a) .d.))
    (cons `(,(inverted-%%go a.) ,(%%go-tag d.) ~%ret)
          (optimize-jumps .d)))
