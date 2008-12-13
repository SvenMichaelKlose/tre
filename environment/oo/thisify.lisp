;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Wrap local method calls into SLOT-VALUEs.

(defun thisify-list (classes x cls)
  (with (clsdesc (href cls classes)
  		 classdef (append (class-methods clsdesc)
						  (class-members clsdesc))
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
			      (if
					(atom x)
	                  (thisify-symbol x exclusions)
					(lambda? x)
					  `#'(,(lambda-args x)
							 ,@(rec (lambda-body x)
									(append exclusions
											(lambda-args x))))
	                (cons (if (%slot-value? x.)
							  `(%slot-value ,(rec (second x.)
												  exclusions)
									        ,(third x.))
		                	  (rec x. exclusions))
			              (rec .x exclusions)))))
      (rec x nil)))

(defun %thisify? (x)
  (and (consp x)
	   (eq '%THISIFY (first x))))
	  
(defun thisify (classes x)
  (with (find-%thisify-exprs
		   (fn (if
				 (atom _)
				   _
				 (%thisify? _.)
				   (append (thisify-list classes
										 (cddr _.)
										 (second _.))
						   (find-%thisify-exprs ._))
				 (traverse #'find-%thisify-exprs _))))
    (find-%thisify-exprs x)))
