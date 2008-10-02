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
	                      (cons (if (%slot-value? (car x))
							        `(%slot-value ,(rec (second (car x)) exclusions)
									              ,(third (car x)))
		                	        (rec (car x) exclusions))
			                    (rec (cdr x) exclusions))))))
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
				      (if (%thisify? (car x))
					      (append (thisify-list classes (cddr (car x)) (second (car x)))
							      (find-them (cdr x)))
					      (cons (find-them (car x))
							    (find-them (cdr x))))))))
    (find-them x)))
