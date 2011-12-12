;;;;; tré - Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defvar *nil-symbol-name* nil)

(defun eq-string= (x y)
  (? (or (symbol? x)
         (symbol? y))
     (eq x y)
     (string= x y)))

(defun compile-file? (file processed-files files-to-update)
  (or (member file files-to-update :test #'eq-string=)
      (not (assoc-value file processed-files :test #'eq-string=))))

(defmacro acons-or-replace (value key place &key (test #'eql))
  (with-gensym (gkey gvalue)
    `(with (,gkey ,key
            ,gvalue ,value)
       (? (assoc-value ,gkey ,place :test ,test)
          (setf (assoc-value ,gkey ,place :test ,test) ,gvalue)
          (acons! ,gkey ,gvalue ,place)))))

(defun target-transpile-2 (tr files files-to-update)
  (let compiled-code (make-queue)
	(dolist (i files (queue-list compiled-code))
      (let code (? (compile-file? i. (transpiler-compiled-files tr) files-to-update)
                   (concat-stringtree (transpiler-transpile tr .i))
                   (assoc-value i. (transpiler-compiled-files tr) :test #'eq-string=))
        (acons-or-replace code i. (transpiler-compiled-files tr) :test #'eq-string=)
	    (enqueue compiled-code code)))))

(defun target-transpile-1 (tr files files-to-update)
  (let sightened-code (make-queue)
	(dolist (i files (queue-list sightened-code))
      (let code (? (compile-file? i. (transpiler-sightened-files tr) files-to-update)
                   (? (symbol? i.) (transpiler-sighten tr (? (function? .i)
                                                             (funcall .i)
                                                             .i))
		  			  (transpiler-sighten-file tr i.))
                   (assoc-value i. (transpiler-sightened-files tr) :test #'eq-string=))
        (acons-or-replace code i. (transpiler-sightened-files tr) :test #'eq-string=)
	    (enqueue sightened-code (cons i. code))))))

(defun target-transpile-generic (tr &key (front-before nil)
							  	   		 (front-after nil)
							  	   		 (back-before nil)
							  	   		 (back-after nil)
								   		 (dep-gen nil)
							 	   		 (decl-gen nil)
                                         (print-obfuscations? nil))
  (with (before-deps (funcall front-before)
		 after-deps (funcall front-after))
	(awhen dep-gen
      (when *have-compiler?*
        (setf *save-compiled-source?* t))
      (acons! 'imported-deps (funcall !) after-deps))
	(with (compiled-before (funcall back-before before-deps)
		   compiled-after (funcall back-after after-deps))
	  (prog1
	    (concat-stringtree
		    (awhen decl-gen
		      (funcall !))
			compiled-before
            (reverse (transpiler-raw-decls tr))
			compiled-after)
        (when print-obfuscations?
          (transpiler-print-obfuscations tr))))))

(defun target-transpile-0 (tr &key (files-after-deps nil)
							  	   (files-before-deps nil)
								   (dep-gen nil)
							 	   (decl-gen nil)
                                   (files-to-update nil)
                                   (print-obfuscations? nil))
  (target-transpile-generic tr
	  :front-before #'(() (target-transpile-1 tr files-before-deps files-to-update))
	  :front-after #'(() (target-transpile-1 tr files-after-deps files-to-update))
	  :back-after #'((processed) (target-transpile-2 tr processed files-to-update))
	  :back-before #'((processed) (target-transpile-2 tr processed files-to-update))
	  :dep-gen dep-gen
	  :decl-gen decl-gen
      :print-obfuscations? print-obfuscations?))

(defvar *updater* nil)

(defun target-transpile (tr &key (files-after-deps nil)
								 (files-before-deps nil)
								 (files-to-update nil)
								 (dep-gen nil)
								 (decl-gen nil)
                                 (print-obfuscations? nil))
  (setf *recompiling?* (? files-to-update t))
  (with-temporary *current-transpiler* tr
	(target-transpile-0 tr :files-after-deps files-after-deps
					  	   :files-before-deps files-before-deps
                           :files-to-update files-to-update
					       :dep-gen dep-gen
						   :decl-gen decl-gen
                           :print-obfuscations? print-obfuscations?)))

(defun target-transpile-setup (tr &key (obfuscate? nil))
  (with-temporary *current-transpiler* tr
    (transpiler-switch-obfuscator tr obfuscate?)
	(make-global-funinfo tr)
    (setf *nil-symbol-name* "NIL")))
