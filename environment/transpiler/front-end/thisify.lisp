; tré – Copyright (c) 2008–2016 Sven Michael Klose <pixel@hugbox.org>

(defun thisify-collect-methods-and-members (clsdesc)
  (+ (class-methods clsdesc)
     (class-members clsdesc)
     (!? (class-parent clsdesc)
         (thisify-collect-methods-and-members !))))

(defun thisify-symbol (classdef x exclusions)
  (? (eq 'this x)
     '~%this
     (!? (& classdef
            (not (member x exclusions :test #'eq))
            (assoc x classdef))
         `(%slot-value ~%this ,x)
         x)))

(defun thisify-list-0 (classdef x exclusions)
  (?
	(symbol? x)       (thisify-symbol classdef x exclusions)
	(| (atom x)
	   (quote? x))    x
    (%slot-value? x)  `(%slot-value ,(thisify-symbol classdef .x. exclusions) ,..x.)
	(lambda? x)       (copy-lambda x :body (thisify-list-0 classdef
                                                           (lambda-body x)
                                                           (+ exclusions (lambda-args x))))
    (listprop-cons x
                   (? (%slot-value? x.)
			          `(%slot-value ,(thisify-list-0 classdef (cadr x.) exclusions)
                                    ,(caddr x.))
                      (thisify-list-0 classdef x. exclusions))
                   (thisify-list-0 classdef .x exclusions))))

(defun thisify-list (classes x cls exclusions)
  (thisify-list-0 (thisify-collect-methods-and-members (href classes cls)) x exclusions))

(def-head-predicate %thisify)

(defun thisify (x &optional (classes (thisify-classes)) (exclusions nil))
  (?
	(atom x)        x
	(%thisify? x.)  (frontend-macroexpansions
                        `((let ~%this this
                            ,@(| (+ (thisify-list classes (cddr x.) (cadr x.) exclusions)
			                        (thisify .x classes exclusions))
                                 '(nil)))))
	(lambda? x.)    (. (copy-lambda x. :body (thisify (lambda-body x.)
                                                      classes
                                                      (+ exclusions (lambda-args x.))))
                       (thisify .x classes exclusions))
    (listprop-cons x (thisify x. classes exclusions)
                     (thisify .x classes exclusions))))
