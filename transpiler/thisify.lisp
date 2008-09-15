;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Wrap local method calls into SLOT-VALUEs.

(defun thisify-list (classes x cls)
  (with (classdef (cdr (assoc cls classes)))
    (with (thisify-symbol
		     #'((x)
                  (aif (and classdef
               				(not (or (numberp x)
                           			 (stringp x)))
						    (assoc x classdef))
                       `(%slot-value this ,x)
					   x))
  	       rec
		     #'((x)
			      (if (atom x)
	                  (thisify-symbol x)
	                  (cons (if (%slot-value? (car x))
							    `(%slot-value ,(rec (second (car x)))
									          ,(third (car x)))
		                	    (rec (car x)))
			                (rec (cdr x))))))
      (rec x))))

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
