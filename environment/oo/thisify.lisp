;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Wrap local method calls into SLOT-VALUEs.

(defun thisify-collect-methods-and-members (clsdesc)
  (append (class-methods clsdesc)
		  (class-members clsdesc)
		  (awhen (class-parent clsdesc)
			(thisify-collect-methods-and-members !))))

(defun thisify-symbol (classdef x exclusions)
  (aif (and classdef
			(not (or (number? x)
           			 (stringp x)))
			(not (find x exclusions))
		    (assoc x classdef))
       `(%slot-value ~%this ,x)
	   x))

(defun thisify-list-0 (classdef x exclusions)
  (?
	(atom x)
      (thisify-symbol classdef x exclusions)
	(%quote? x)
	  x
	(lambda? x)
	  `#'(,@(lambda-funinfo-expr x)
		  ,(lambda-args x)
		  ,@(thisify-list-0 classdef
				 		   (lambda-body x)
				 		   (append exclusions
								   (lambda-args x))))
    (cons (? (%slot-value? x.)
			 `(%slot-value ,(thisify-list-0 classdef (second x.) exclusions)
					        ,(third x.))
			 (thisify-list-0 classdef x. exclusions))
		  (thisify-list-0 classdef .x exclusions))))

;; Thisify class members inside found %THISIFY.
(defun thisify-list (classes x cls)
  (thisify-list-0 (thisify-collect-methods-and-members
				      (href classes cls))
				      x
				      nil))

(def-head-predicate %thisify)

;; Search %THISIFY-expressions and treat them accordingly.
(defun thisify (classes x)
  (?
	 (atom x)
	   x
	 (%thisify? x.)
	   (append (thisify-list classes
							 (cddr x.)
							 (second x.))
			   (thisify classes .x))
	 (cons (thisify classes x.)
	 	   (thisify classes .x))))
