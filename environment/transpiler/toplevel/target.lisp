;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defvar *nil-symbol-name* nil)

(defun recompile-file? (file files-to-update)
  (and (not (eq 'text file.))
	   (member file. files-to-update :test #'string=)))

(defun target-transpile-recompile-2 (tr new old files-to-update)
  (mapcar #'((n o)
			   (format t "Recompiling backend file ~A~%" n.)
			   (concat-stringtree (? (recompile-file? n files-to-update)
				                     (transpiler-transpile tr .n)
					                 o)))
		  new old))

(defun target-transpile-2 (tr files)
  (mapcar (fn concat-stringtree (transpiler-transpile tr ._)) files))

(defun target-transpile-1 (tr files)
  (let sightened-code nil
	(dolist (i files sightened-code)
	  (append! sightened-code
			   (list (cons i. (? (eq 'text i.)
		  				         (transpiler-sighten tr .i)
		  				         (transpiler-sighten-files tr (list i.)))))))))

(defun target-transpile-generic (tr &key (files-before-deps nil)
										 (files-after-deps nil)
										 (front-before nil)
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
      (acons! 'text (funcall !) after-deps))
    (format t "; Let me think. Hmm...~%")
	(with (compiled-before (funcall back-before before-deps)
		   compiled-after (funcall back-after after-deps))
	  (prog1
	    (concat-stringtree (awhen decl-gen
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
                                   (print-obfuscations? nil))
  (target-transpile-generic tr
	  :files-before-deps files-before-deps
	  :files-after-deps files-after-deps
	  :front-before #'(()
  			            (target-transpile-1 tr files-before-deps))
	  :front-after #'(()
		 	           (target-transpile-1 tr files-after-deps))
	  :back-after #'((processed)
			          (target-transpile-2 tr processed))
	  :back-before #'((processed)
	  		           (target-transpile-2 tr processed))
	  :dep-gen dep-gen
	  :decl-gen decl-gen
      :print-obfuscations? print-obfuscations?))

(defun target-transpile-ok ()
  (format t "~%; Everything OK. Done.~%"))

(defvar *updater* nil)

(defun target-transpile (tr &key (files-after-deps nil)
								 (files-before-deps nil)
								 (files-to-update nil)
								 (dep-gen nil)
								 (decl-gen nil)
								 (make-updater nil)
                                 (print-obfuscations? nil))
  (with-temporary *current-transpiler* tr
    (prog1
	  (target-transpile-0 tr :files-after-deps files-after-deps
						  	 :files-before-deps files-before-deps
						     :dep-gen dep-gen
							 :decl-gen decl-gen
                             :print-obfuscations? print-obfuscations?)
	  (target-transpile-ok)
	  (awhen make-updater
		(sys-image-create ! #'(()))))))

(defun target-transpile-setup (tr &key (obfuscate? nil))
  (with-temporary *current-transpiler* tr
    (transpiler-switch-obfuscator tr obfuscate?)
	(make-global-funinfo tr)
    (setf *nil-symbol-name* (symbol-name (transpiler-obfuscate-nil tr)))))
