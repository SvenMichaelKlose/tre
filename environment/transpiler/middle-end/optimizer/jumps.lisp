(fn inverted-%%go (x)
  (case x
    '%%go-nil      '%%go-not-nil
    '%%go-not-nil  '%%go-nil
    (funinfo-error "Jump expected instead of ~A." x)))

(fn jumps-to-tag (x)
  (count-if [& (vm-jump? _)
               (== x (%%go-tag _))]
            *body*))

(fn constant-jump? (x constant)
  (| (? constant
        (%%go-not-nil? x)
        (%%go-nil? x))
     (%%go? x)))

(fn target-tag (x constant)
  (?
    (not x)
      nil
    (number? x.)
      (target-tag .x constant)
    (constant-jump? x. constant)
      (| (target-tag (member (%%go-tag x.) *body*) constant)
         (%%go-tag x.))))

(fn setting-ret-to-bool? (x)
  (& (%=? x)
     (~%ret? .x.)
     (| (not ..x.)
        (eq t ..x.))))

(define-optimizer optimize-jumps
  (& (%%go-cond? a)
     (let dest (cdr (tag-code (%%go-tag a)))
       (& (%%go-cond? dest.)
          (eq a. dest..))))
    (. `(,a. ,(%%go-tag (cadr (tag-code (%%go-tag a))))
             ,(%%go-value a))
       (optimize-jumps d))
  (& (setting-ret-to-bool? a)
     (!? (target-tag d ..a.)
         (not (will-be-used-again? (member ! *body*) *return-id*))))
    (. `(%%go ,(target-tag d ..a.))
       (optimize-jumps d))
  (& (setting-ret-to-bool? a)
     (? ..a.
        (%%go-nil? d.)
        (%%go-not-nil? d.)))
    (. a (optimize-jumps .d))
  (& (%%go-cond? a)
     (%%go? d.)
     (number? .d.)
     (== (%%go-tag a) .d.))
    (. `(,(inverted-%%go a.) ,(%%go-tag d.) ,(%%go-value a))
       (optimize-jumps .d)))
