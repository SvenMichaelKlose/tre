;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defvar *nil-symbol-name* "NIL")
(defvar *t-symbol-name* "T")

(defun eq-string= (x y)
  (? (or (symbol? x)
         (symbol? y))
     (eq x y)
     (string= x y)))

(defun compile-file? (file processed-files files-to-update)
  (or (member file files-to-update :test #'eq-string=)
      (not (assoc-value file processed-files :test #'eq-string=))))

(defun target-transpile-2 (tr files files-to-update)
  (let compiled-code (make-queue)
	(dolist (i files (queue-list compiled-code))
      (let code (? (compile-file? i. (transpiler-compiled-files tr) files-to-update)
                   (transpiler-make-code tr .i)
                   (assoc-value i. (transpiler-compiled-files tr) :test #'eq-string=))
        (assoc-adjoin code i. (transpiler-compiled-files tr) :test #'eq-string=)
	    (enqueue compiled-code code)))))

(defun target-transpile-1 (tr files files-to-update)
  (let sightened-code (make-queue)
	(dolist (i files (queue-list sightened-code))
      (let code (? (compile-file? i. (transpiler-sightened-files tr) files-to-update)
                   (? (symbol? i.)
                      (transpiler-sighten tr (? (function? .i)
                                                (funcall .i)
                                                .i))
		  			  (transpiler-sighten-file tr i.))
                   (assoc-value i. (transpiler-sightened-files tr) :test #'eq-string=))
        (assoc-adjoin code i. (transpiler-sightened-files tr) :test #'eq-string=)
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
        (setf *save-compiled-source?* t)
        (clr *save-args-only?*))
      (acons! 'imported-deps (funcall !) after-deps))
	(with (compiled-before (funcall back-before before-deps)
		   compiled-after (funcall back-after after-deps))
	  (prog1
	    (concat-stringtree (awhen decl-gen
		                     (funcall !))
			               compiled-before
                           (reverse (transpiler-raw-decls tr))
			               compiled-after)
        (when (and print-obfuscations? (transpiler-obfuscate? tr))
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
                                 (obfuscate? nil)
                                 (print-obfuscations? nil))
  (with-temporary *recompiling?* (? files-to-update t)
    (when files-to-update
      (clr (transpiler-emitted-decls tr)))
    (transpiler-switch-obfuscator tr obfuscate?)
    (with-temporary *current-transpiler* tr
	  (target-transpile-0 tr :files-after-deps files-after-deps
					  	     :files-before-deps files-before-deps
                             :files-to-update files-to-update
					         :dep-gen dep-gen
						     :decl-gen decl-gen
                             :print-obfuscations? print-obfuscations?))))
