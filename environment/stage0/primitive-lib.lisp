;;;;; tré – Copyright (c) 2006–2009,2012–2014 Sven Michael Klose <pixel@copei.de>

(setq *show-definitions?* t)

(setq
	*universe* ; The garbage collector roots here.
	(cons 'list
	(cons 'last
	(cons '%nconc
	(cons 'copy-list
	(cons '*variables*
		  *universe*))))))

(setq
	*defined-functions*
	(cons 'list
	(cons 'identity
	(cons 'copy-list
	(cons 'last
	(cons '%nconc
		  nil))))))

(setq
	*variables*
	(cons (cons '*variables* nil)
	(cons (cons '*defined-functions* nil)
	(cons (cons '*universe* nil)
	(cons (cons '*keyword-package* nil)
	(cons (cons '*show-definitions?* nil)
	(cons (cons '*environment-path* nil)
	(cons (cons '*endianess* nil)
	(cons (cons '*pointer-size* nil)
	(cons (cons '*cpu-type* nil)
	(cons (cons '*libc-path* nil)
	(cons (cons '*have-environment-tests* nil)
	(cons (cons '*rand-max* nil)
	(cons (cons '*default-listprop* nil)
	(cons (cons '*exception* nil)
	(cons (cons '*backtrace* nil)
	(cons (cons '*assert* nil)
		  *variables*)))))))))))))))))

(%set-atom-fun identity #'((x) x))
(%set-atom-fun list #'((&rest x) x))

(%set-atom-fun copy-list
  #'((x)
      (? x
		 (? (atom x)
            x
            (progn
              (? (cpr x)
                 (setq *default-listprop* (cpr x)))
              (#'((p c)
                    (rplacp c (setq *default-listprop* p)))
                *default-listprop*
                (cons (car x)
              	      (copy-list (cdr x)))))))))

(%set-atom-fun last
  #'((x)
      (? x
		 (? (cdr x)
            (last (cdr x))
            x))))

(%set-atom-fun %nconc
  #'((a b)
      (? a
         (progn
		   (rplacd (last a) b)
    	   a)
		 b)))
