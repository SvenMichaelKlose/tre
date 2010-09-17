;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defvar *nil-symbol-name* nil)

(defun target-transpile-2 (tr files)
  (mapcar (fn concat-stringtree (transpiler-transpile tr ._))
		  files))

(defun target-transpile-1 (tr files)
  (let sightened-code nil
	(dolist (i files sightened-code)
	  (append! sightened-code
			   (list (cons i.
	  				       (if (eq 'text i.)
		  				       (transpiler-sighten tr .i)
		  				       (transpiler-sighten-files tr (list .i)))))))))

(defun target-transpile-0 (tr &key (files nil)
							  	   (files-before-deps nil)
								   (dep-gen nil)
							 	   (decl-gen nil))
  (with (before-deps (target-transpile-1 tr files-before-deps)
		 after-deps (target-transpile-1 tr files))
	(format t "; Importing dependencies....~%")
  	(force-output)
	(awhen dep-gen
      (push! (cons 'text
				   (funcall !))
		     after-deps))
	; Generate.
    (format t "; Let me think. Hmm")
  	(force-output)
	(prog1
	  (with (compiled-before (target-transpile-2 tr before-deps)
			 compiled-after (target-transpile-2 tr after-deps))
	    (concat-stringtree
		    (awhen decl-gen
		      (funcall !))
			compiled-before
			compiled-after))
      (transpiler-print-obfuscations tr))))

(defun target-transpile-ok ()
  (format t "~%; Everything OK. ~A instructions. Done.~%"
			*codegen-num-instructions*))

(defun target-transpile-updated (tr))

(defun target-transpile (tr &key (files nil)
								 (files-before-deps nil)
								 (dep-gen nil)
								 (decl-gen nil)
								 (make-compiler? nil))
  (with-temporary *current-transpiler* tr
    (prog1
	  (target-transpile-0 tr :files files :files-before-deps files-before-deps
						     :dep-gen dep-gen :decl-gen decl-gen)
	  (target-transpile-ok)
	  (awhen make-compiler?
		  (sys-image-create ! #'(()
								   (target-transpile-updated tr)))))))

(defun target-transpile-setup (tr &key (obfuscate? nil))
  (with-temporary *current-transpiler* tr
    (transpiler-switch-obfuscator tr obfuscate?)
	(make-global-funinfo)
    (setf *nil-symbol-name* (symbol-name (transpiler-obfuscate-nil tr)))))
