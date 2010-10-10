;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defvar *nil-symbol-name* nil)

(defun recompile-file? (file files-to-update)
  (and (not (eq 'text file.))
	   (member file. files-to-update :test #'string=)))

(defun target-transpile-recompile-2 (tr new old files-to-update)
  (mapcar #'((n o)
			   (format t "Recompiling backend file ~A~%" n.)
			   (concat-stringtree
			       (if (recompile-file? n files-to-update)
				       (transpiler-transpile tr .n)
					   o)))
		  new old))

(defun target-transpile-2 (tr files)
  (mapcar (fn concat-stringtree (transpiler-transpile tr ._))
		  files))

(defun target-transpile-recompile-1 (tr compiled-files files-to-update)
  (let sightened-code nil
	(dolist (i compiled-files sightened-code)
  	  (format t "Recompiling frontend file ~A~%" i.)
	  (append! sightened-code
			   (list (if (recompile-file? i files-to-update)
						 (cons i.
		  				       (transpiler-sighten-files tr (list i.)))
		  				 i))))))

(defun target-transpile-1 (tr files)
  (let sightened-code nil
	(dolist (i files sightened-code)
	  (append! sightened-code
			   (list (cons i.
	  				       (if (eq 'text i.)
		  				       (transpiler-sighten tr .i)
		  				       (transpiler-sighten-files tr (list i.)))))))))

(defun target-transpile-save-compiled (tr &key (files-after-deps nil)
							  	   			   (files-before-deps nil)
								   			   (dep-gen nil)
							 	   			   (decl-gen nil))
  (setf (transpiler-re-back-after-deps tr) files-after-deps)
  (setf (transpiler-re-back-before-deps tr) files-before-deps)
  (setf (transpiler-re-dep-gen tr) dep-gen)
  (setf (transpiler-re-decl-gen tr) decl-gen))

(defun target-transpile-generic (tr &key (files-before-deps nil)
										 (files-after-deps nil)
										 (front-before nil)
							  	   		 (front-after nil)
							  	   		 (back-before nil)
							  	   		 (back-after nil)
								   		 (dep-gen nil)
							 	   		 (decl-gen nil)
                                         (print-obfuscations? nil))
  (setf (transpiler-re-files-after-deps tr) files-after-deps)
  (setf (transpiler-re-files-before-deps tr) files-before-deps)
  (with (before-deps (funcall front-before)
		 after-deps (funcall front-after))
	(format t "; Importing dependencies....~%")
  	(force-output)
	(awhen dep-gen
      (push! (cons 'text
				   (funcall !))
		     after-deps))
    (format t "; Let me think. Hmm")
  	(force-output)
    (setf (transpiler-re-front-after-deps tr) after-deps)
    (setf (transpiler-re-front-before-deps tr) before-deps)
	(with (compiled-before (funcall back-before before-deps)
		   compiled-after (funcall back-after after-deps))
	  (prog1
	    (concat-stringtree
		    (awhen decl-gen
		      (funcall !))
			compiled-before
			compiled-after)
	    (target-transpile-save-compiled tr :files-before-deps compiled-before
									       :files-after-deps compiled-after
										   :dep-gen dep-gen
										   :decl-gen decl-gen)
        (when print-obfuscations?
          (transpiler-print-obfuscations tr))))))

(defun target-transpile-recompile-0 (tr &key (files-after-deps nil)
							  	   			 (files-before-deps nil)
								   			 (dep-gen nil)
							 	   			 (decl-gen nil)
											 (files-to-update nil))

  (target-transpile-generic tr
	  :front-before
  		  #'(()
			   (target-transpile-recompile-1 tr
				   (transpiler-re-front-before-deps tr)
				   files-to-update))
	  :front-after
  		  #'(()
			   (target-transpile-recompile-1 tr
				   (transpiler-re-front-after-deps tr)
				   files-to-update))
	  :back-after
  		  #'((processed)
	  		   (target-transpile-recompile-2 tr
				   processed
				   (transpiler-re-back-after-deps tr)
				   files-to-update))
	  :back-before
  		  #'((processed)
	  		   (target-transpile-recompile-2 tr
				   processed
				   (transpiler-re-back-before-deps tr)
				   files-to-update))
	  :dep-gen dep-gen
	  :decl-gen decl-gen))

(defun target-transpile-0 (tr &key (files-after-deps nil)
							  	   (files-before-deps nil)
								   (dep-gen nil)
							 	   (decl-gen nil)
                                   (print-obfuscations? nil))
  (target-transpile-generic tr
	  :files-before-deps files-before-deps
	  :files-after-deps files-after-deps
	  :front-before
  		  #'(()
  			   (target-transpile-1 tr files-before-deps))
	  :front-after
  		  #'(()
		 	   (target-transpile-1 tr files-after-deps))
	  :back-after
  		  #'((processed)
			   (target-transpile-2 tr processed))
	  :back-before
  		  #'((processed)
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
	    (setf *updater*
			  #'((tr &rest files-to-update)
	  			   (target-transpile-recompile-0 tr
					   :files-after-deps
					       (transpiler-re-files-after-deps tr)
					   :files-before-deps
					   	   (transpiler-re-files-before-deps tr)
					   :dep-gen
					       (transpiler-re-dep-gen tr)
					   :decl-gen
					   	   (transpiler-re-decl-gen tr))))
		(sys-image-create ! #'(()))))))

(defun target-transpile-setup (tr &key (obfuscate? nil))
  (with-temporary *current-transpiler* tr
    (transpiler-switch-obfuscator tr obfuscate?)
	(make-global-funinfo)
    (setf *nil-symbol-name* (symbol-name (transpiler-obfuscate-nil tr)))))
