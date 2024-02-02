(fn inverted-%go (x)
  (case x
    '%go-nil      '%go-not-nil
    '%go-not-nil  '%go-nil
    (funinfo-error "Jump expected instead of ~A." x)))

(fn jumps-to-tag (x)
  (count-if [& (some-%go? _)
               (== x (%go-tag _))]
            *body*))

(fn constant-jump? (x constant)
  (| (? constant
        (%go-not-nil? x)
        (%go-nil? x))
     (%go? x)))

(fn target-tag (x constant)
  (?
    (not x)
      nil
    (number? x.)
      (target-tag .x constant)
    (constant-jump? x. constant)
      (| (target-tag (member (%go-tag x.) *body*) constant)
         (%go-tag x.))))

(fn setting-ret-to-bool? (x)
  (& (%=? x)
     (~%ret? (%=-place x))
     (bool? (%=-value x))))

(fn jump-to-same-jump? (x)
  (& (some-%go? x)
     (!= (cdr (tag-code (%go-tag x)))
       (? (%go-cond? x)
          (? (%go-cond? !.)
             (eq x. !..)
             (%go? !.))
          (%go? !.)))))

(fn fnord? (a d)
  (& (setting-ret-to-bool? a)
     (!? (target-tag d ..a.)
         (not (will-be-used-again? (member ! *body*) *return-id*)))))

(fn before-static-cond? (a d)
  (& (setting-ret-to-bool? a)
     (? ..a.
        (%go-nil? d.)
        (%go-not-nil? d.))))

(fn inverting-cond-over-jump? (a d)
  (& (%go-cond? a)
     (%go? d.)
     (number? .d.)
     (== (%go-tag a) .d.)))

(define-optimizer optimize-jumps
  (jump-to-same-jump? a)
    (. `(,a. ,(%go-tag (cadr (tag-code (%go-tag a))))
             ,@(? (%go-cond? a)
                  (… (%go-value a))))
       (optimize-jumps d))
  (fnord? a d)
    (. `(%go ,(target-tag d ..a.))
       (optimize-jumps d))
  (before-static-cond? a d)
    (. a (optimize-jumps .d))
  (inverting-cond-over-jump? a d)
    (. `(,(inverted-%go a.) ,(%go-tag d.) ,(%go-value a))
       (optimize-jumps .d)))
