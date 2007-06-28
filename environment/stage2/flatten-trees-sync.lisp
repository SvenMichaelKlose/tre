;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>

;; Flatten list a and list b synchronuously, determined by (superior) list a.
;; Sub-lists may remain in (inferior) list b. If list b is missing sublevels or
;; elements, an error is issued.
(defun flatten-trees-sync! (la lb)
  (when la
    (let ((ea (car la))
	  (eb (car lb))
          (na (cdr la))
          (nb (cdr lb)))
      (if (not (listp ea))
        (flatten-trees-sync! na nb)
        (progn
          (unless (listp eb)
            (error "missing sublevel list in inferior list"))
          (flatten-trees-sync! ea eb)
          (rplaca la (car ea))
          (rplacd la (cdr ea))
          (rplaca lb (car eb))
          (rplacd lb (cdr eb))
          (flatten-trees-sync! na nb)
          (nconc la na)
          (nconc lb nb))))))
