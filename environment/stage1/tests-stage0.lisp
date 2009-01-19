;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Testing stage 0 functions

;(define-test "%NCONC"
;  ((%nconc '(1 2) '(3 4)))
;  '(1 2 3 4))

(define-test "%NCONC with NIL first"
  ((%nconc nil '(3 4)))
  '(3 4))

(define-test "%NCONC with NIL second"
  ((%nconc '(1 2) nil))
  '(1 2))

(define-test "LENGHT with conses"
  ((length '(1 2 3 4)))
  (integer 4))

(define-test "LENGHT with strings"
  ((length "test"))
  (integer 4))
