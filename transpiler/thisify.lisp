;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Wrap local method calls into SLOT-VALUEs.

(defun thisify-list (classes x cls)
  (with (clsdesc (cdr (assoc cls classes))
  		 classdef (append (js-class-methods clsdesc)
						  (js-class-members clsdesc))
    	 thisify-symbol
		     #'((x exclusions)
                  (aif (and classdef
               				(not (or (numberp x)
                           			 (stringp x)))
							(not (find x exclusions))
						    (assoc x classdef))
                       `(%slot-value this ,x)
					   x))
  	       rec
		     #'((x exclusions)
			      (if (atom x)
	                  (thisify-symbol x exclusions)
					  (if (is-lambda? x)
						  `#'(,(lambda-args x)
							   ,@(rec (lambda-body x) (append exclusions (lambda-args x))))
	                      (cons (if (%slot-value? x.)
							        `(%slot-value ,(rec (second x.) exclusions)
									              ,(third x.))
		                	        (rec x. exclusions))
			                    (rec .x exclusions))))))
      (rec x nil)))

(defun %thisify? (x)
  (and (consp x)
	   (eq '%THISIFY (first x))))
	  
(defun thisify (classes x)
  (with (find-them
		   #'((x)
				(when x
				  (if (atom x)
					  x
				      (if (%thisify? x.)
					      (append (thisify-list classes (cddr x.) (second x.))
							      (find-them .x))
					      (cons (find-them x.)
							    (find-them .x)))))))
    (find-them x)))
