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
      (not (assoc file processed-files :test #'eq-string=))))

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
                      (transpiler-sighten tr (? (function? .i) (funcall .i) .i))
		  			  (transpiler-sighten-file tr i.))
                   (assoc-value i. (transpiler-sightened-files tr) :test #'eq-string=))
        (assoc-adjoin code i. (transpiler-sightened-files tr) :test #'eq-string=)
	    (enqueue sightened-code (cons i. code))))))

(defun target-sighten-deps (tr dep-gen)
  (when dep-gen
    (when *have-compiler?*
      (setf *save-compiled-source?* t)
      (clr *save-args-only?*))
    (funcall dep-gen)))

(defun target-transpile (tr &key (files-before-deps nil)
                                 (files-after-deps nil)
                                 (files-to-update nil)
                                 (dep-gen nil)
                                 (decl-gen nil)
                                 (obfuscate? nil)
                                 (print-obfuscations? nil))
  (with-temporaries (*recompiling?* (? files-to-update t)
                     *current-transpiler* tr)
    (when files-to-update
      (clr (transpiler-emitted-decls tr)))
    (transpiler-switch-obfuscator tr obfuscate?)
    (with (before-deps (target-transpile-1 tr files-before-deps files-to-update)
		   after-deps  (target-transpile-1 tr files-after-deps files-to-update)
		   deps        (target-sighten-deps tr dep-gen)
	       compiled-before (target-transpile-2 tr before-deps files-to-update)
	       compiled-deps   (awhen deps (transpiler-make-code tr !))
		   compiled-after  (target-transpile-2 tr after-deps files-to-update))
      (awhen compiled-deps
        (setf (transpiler-imported-deps tr) (string-concat (transpiler-imported-deps tr) !)))
	  (prog1
	    (concat-stringtree (awhen decl-gen
	                         (funcall !))
	                       compiled-before
                           (reverse (transpiler-raw-decls tr))
                           (transpiler-imported-deps tr)
	                       compiled-after)
        (when (and print-obfuscations? (transpiler-obfuscate? tr))
          (transpiler-print-obfuscations tr))))))
