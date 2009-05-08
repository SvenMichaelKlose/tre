;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Wrap local method calls into SLOT-VALUEs.

(defun thisify-collect-methods-and-members (clsdesc)
  (append (class-methods clsdesc)
		  (class-members clsdesc)
		  (awhen (class-parent clsdesc)
			(thisify-collect-methods-and-members !))))

(defun thisify-symbol (classdef x exclusions)
  (aif (and classdef
			(not (or (numberp x)
           			 (stringp x)))
			(not (find x exclusions))
		    (assoc x classdef))
       `(%slot-value this ,x)
	   x))

(defun thisify-list-0 (classdef x exclusions)
  (if
	(atom x)
      (thisify-symbol classdef x exclusions)
	(lambda? x)
	  `#'(,@(lambda-funinfo-expr x)
		  ,(lambda-args x)
		  ,@(thisify-list-0 classdef
				 		   (lambda-body x)
				 		   (append exclusions
								   (lambda-args x))))
    (cons (if (%slot-value? x.)
			  `(%slot-value ,(thisify-list-0 classdef
								 			 (second x.)
								  			 exclusions)
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
  (if
	 (atom x)
	   x
	 (%thisify? x.)
	   (append (thisify-list classes
							 (cddr x.)
							 (second x.))
			   (thisify classes .x))
	 (cons (thisify classes x.)
	 	   (thisify classes .x))))
