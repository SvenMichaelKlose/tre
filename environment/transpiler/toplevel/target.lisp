;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defvar *nil-symbol-name* nil)

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
                   (concat-stringtree (transpiler-transpile tr .i))
                   (assoc-value i. (transpiler-compiled-files tr) :test #'eq-string=))
        (? (assoc-value i. (transpiler-compiled-files tr) :test #'eq-string=)
           (setf (assoc-value i. (transpiler-compiled-files tr) :test #'eq-string=) code)
           (acons! i. code (transpiler-compiled-files tr)))
	    (enqueue compiled-code code)))))

(defun target-transpile-1 (tr files files-to-update)
  (let sightened-code (make-queue)
	(dolist (i files (queue-list sightened-code))
      (let code (? (compile-file? i. (transpiler-sightened-files tr) files-to-update)
                   (? (symbol? i.)
		  			  (transpiler-sighten tr .i)
		  			  (transpiler-sighten-files tr (list i.)))
                   (assoc-value i. (transpiler-sightened-files tr) :test #'eq-string=))
        (? (assoc-value i. (transpiler-sightened-files tr) :test #'eq-string=)
           (setf (assoc-value i. (transpiler-sightened-files tr) :test #'eq-string=) code)
           (acons! i. code (transpiler-sightened-files tr)))
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
	(format t "; Importing dependencies...~%")
	(awhen dep-gen
      (acons! 'imported-deps (funcall !) after-deps))
    (format t "; Let me think. Hmm...")
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
	  :front-before
  		  #'(()
  			   (target-transpile-1 tr files-before-deps files-to-update))
	  :front-after
  		  #'(()
		 	   (target-transpile-1 tr files-after-deps files-to-update))
	  :back-after
  		  #'((processed)
			   (target-transpile-2 tr processed files-to-update))
	  :back-before
  		  #'((processed)
	  		   (target-transpile-2 tr processed files-to-update))
	  :dep-gen dep-gen
	  :decl-gen decl-gen
      :print-obfuscations? print-obfuscations?))

(defun target-transpile-ok ()
  (format t "~%; Code has been generated.~%"))

(defvar *updater* nil)

(defun target-transpile (tr &key (files-after-deps nil)
								 (files-before-deps nil)
								 (files-to-update nil)
								 (dep-gen nil)
								 (decl-gen nil)
                                 (print-obfuscations? nil))
  (setf *recompiling?* (? files-to-update t))
  (with-temporary *current-transpiler* tr
    (prog1
	  (target-transpile-0 tr :files-after-deps files-after-deps
						  	 :files-before-deps files-before-deps
                             :files-to-update files-to-update
						     :dep-gen dep-gen
							 :decl-gen decl-gen
                             :print-obfuscations? print-obfuscations?)
	  (target-transpile-ok))))

(defun target-transpile-setup (tr &key (obfuscate? nil))
  (with-temporary *current-transpiler* tr
    (transpiler-switch-obfuscator tr obfuscate?)
	(make-global-funinfo tr)
    (setf *nil-symbol-name* "NIL")))
