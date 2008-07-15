;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun tree-list (x)
  (if (atom x)
	  x
      (if (consp (car x))
	      (nconc (tree-list (car x))
			     (tree-list (cdr x)))
	      (cons (car x)
			    (tree-list (cdr x))))))

(defun maptree (fun tree)
  (if (atom tree)
	  tree
      (mapcar #'((x)
                  (if (consp x)
                      (funcall fun (maptree fun (funcall fun x)))
                      (funcall fun x)))
              tree)))

;;;; TRANSPILER CONFIGURATION

(defstruct transpiler
  preprocessor
  rename-prefix
  std-macro-renamer
  std-macro-expander
  macro-expander
  separator
  (function-args nil)
  (wanted-functions nil))

(defun create-transpiler (&rest args)
  (with (tr (apply #'make-transpiler args))
    (define-expander (transpiler-preprocessor tr)
					 nil nil
					 nil #'(lambda (fun x)
							 (transpiler-preprocessor-call tr fun x)))
    (define-expander (transpiler-std-macro-renamer tr))
    (define-expander (transpiler-std-macro-expander tr))
	(define-expander (transpiler-macro-expander tr)
					 nil nil
					 nil #'(lambda (fun x)
							 (transpiler-macrocall tr fun x)))
	tr))

;;; OPERATOR EXPANSION

(defmacro define-transpiler-infix (tr name)
  `(define-expander-macro ,(transpiler-macro-expander (eval tr)) ,name (x y)
	 `(,,x (string ',name) ,,y)))

(defun transpiler-binary-expand (op args)
  (nconc (list "(")
		 (mapcan #'(lambda (x)
					 `(,x ,op))
				 (butlast args))
		 (last args)
		 (list ")")))

(defmacro define-transpiler-binary (tr op repl-op)
  `(define-expander-macro ,(transpiler-macro-expander (eval tr)) ,op (&rest args)
     (transpiler-binary-expand ,repl-op args)))

;;;; PREPROCESSING

(defmacro define-transpiler-preprocessor (tr name args body)
  `(define-expander-macro ,(transpiler-preprocessor (eval tr)) ,name ,args ,body))

(defun transpiler-preprocessor-call (tr fun x)
  (apply (cdr (assoc fun (expander-macros (expander-get (transpiler-preprocessor tr))))) tr x))

(defun transpiler-encapsulate-strings (form)
  (maptree #'((x)
               (if (stringp x)
                   (list '%transpiler-string x)
                   x))
           form))

;;;; STANDARD MACRO RENAMING

(defun transpiler-std-rename-symbol (tr name)
 ($ (transpiler-rename-prefix tr) name))

(defmacro define-transpiler-rename (tr name)
  `(define-expander-macro ,(transpiler-std-macro-renamer (eval tr)) ,name (&rest args)
     `(,(transpiler-std-rename-symbol (eval tr) name) ,,@args)))

;;;; STANDARD MACRO EXPANSION

(defun transpiler-macroexpand (x)
  (repeat-while-changes #'((x) (*macroexpand-hook* x)) x))

;;;; EXPANSION OF RENAMED STANDARD MACROS

(defmacro define-transpiler-std-macro (tr name args body)
  (with (tre (eval tr))
    (when (expander-has-macro? (transpiler-std-macro-renamer tre) name)
	  (error "DEFINE-JS-STD-MACRO: ~A already defined" name))
    `(progn
	   (define-js-rename ,name)
       (define-expander-macro ,(transpiler-std-macro-expander tre)
							  ,(transpiler-std-rename-symbol tre name)
							  ,args
		 ,body))))

;;;; LAMBDA EXPANSION

(defun transpiler-lambda-expand (x)
  (with ((forms inits)  (values nil nil) ; (copy-tree (function-arguments fun)))
         fi             (make-funinfo :env (list forms nil)))
    (lambda-embed-or-export x fi nil)))

;;;; ARGUMENT EXPANSION

(defun transpiler-expand-argdef (tr x)
  (or (cdr (assoc x (transpiler-function-args tr)))
      (function-arguments (symbol-function x))))

(defun transpiler-add-wanted-function (tr fun)
  (when (not (member fun (transpiler-wanted-functions tr)))
	(push fun (transpiler-wanted-functions tr))))

(defun transpiler-expand-args (tr x)
  (with (fname  (first (third x))
		 d (transpiler-expand-argdef tr fname))
	(if d
        (cdrlist (argument-expand d (cdr (third x)) t))
		(progn
		   (transpiler-add-wanted-function tr fname)
		   (cdr (third x))))))

(defun transpiler-finalize-sexprs (tr x)
  (when x
	(with (e          (car x)
		   separator  (transpiler-separator tr))
	  (if (atom e) ; Jump label.
		  (cons (string-concat (symbol-name e) (format nil ":~%"))
		        (transpiler-finalize-sexprs tr (cdr x)))
          (if (and (%setq? e) (is-lambda? (caddr e))) ; Recurse into function.
	          (cons `(%setq ,(second e) (function
							              (lambda ,(lambda-args (caddr e))
							                ,@(transpiler-finalize-sexprs tr (lambda-body (caddr e))))))
			        (cons separator
						  (transpiler-finalize-sexprs tr (cdr x))))
	          (if (and (identity? e) (eq '~%ret (second e))) ; Remove (IDENTITY ~%RET).
		          (transpiler-finalize-sexprs tr (cdr x))
				  ; Just copy with seperator. Make return-value assignment if missing.
		          (cons (if (and (consp e) (not (or (vm-jump? e) (%setq? e))))
							`(%setq ~%ret ,e)
							e)
						(cons separator
							  (transpiler-finalize-sexprs tr (cdr x))))))))))

;;;; TRANSPILER-MACRO EXPANDER

(defun transpiler-macrop-funcall? (x)
  (and (consp x)
	   (%setq? x)
	   (consp (third x))
	   (not (stringp (first (third x))))
	   (not (in? (first (third x)) '%transpiler-string '%transpiler-native))))

(defun transpiler-macrocall-funcall (x)
  (transpiler-binary-expand "," x))

(defun transpiler-macrocall (tr fun x)
  (with (m (cdr (assoc fun (expander-macros (expander-get (transpiler-macro-expander tr))))))
    (if m
        (with (e (apply m x))
	       (if (transpiler-macrop-funcall? `(,fun ,@x))
  		       `(,(first e) ,(second e) ,(first (third e)) ,@(transpiler-macrocall-funcall (cdr (third e))))
		       e))
		`(,fun ,@x))))

(defmacro define-transpiler-macro (tr name args body)
  `(define-expander-macro ,(transpiler-macro-expander (eval tr)) ,name ,args ,body))

;;;; POST PROCESSING

(defun transpiler-special-char? (tr x)
  (in=? x #\% #\~))

(defun transpiler-symbol-string (tr s)
  (with (convert-camel
		   #'((x)
				(when x
			      (with (c (char-downcase (car x)))
			        (if (or (in=? c #\*)
							(and (eq #\- c) (cdr x)))
				        (when (cdr x)
						  (cons (char-upcase (cadr x))
							    (convert-camel (cddr x))))
					    (cons c (convert-camel (cdr x)))))))
		 convert-special
		   #'((x)
				(when x
			      (with (c (car x))
				    (aif (transpiler-special-char? tr c)
					     (append (string-list (string-concat "T" (format nil "~A" (char-code c))))
								 (convert-special (cdr x)))
					     (cons c (convert-special (cdr x)))))))
		 str (string s)
	     l (length str))
    (list-string
	  (append
	    (convert-special
          (if (and (< 2 (length str))
			       (= (elt str 0) #\*)
			       (= (elt str (1- l)) #\*))
		      (remove-if #'((x)
						      (= x #\-))
					     (string-list (string-upcase (subseq str 1 (1- l)))))
    	      (convert-camel (string-list str))))
	    (list #\ )))))

(defun transpiler-to-string (tr x)
  (maptree #'((e)
				(cond
				  ((numberp e) (format nil "~A" e))
				  ((consp e)   (if (eq (car e) '%transpiler-string)
								   (string-concat "\"" (cadr e) "\"")
									(if (eq (car e) '%transpiler-native)
										(transpiler-to-string tr (cdr e))
										e)))
				  ((stringp e) e)
				  (t		   (if (eq nil e)
								   "null"
								   (transpiler-symbol-string tr e)))))
		   x))

(defun transpiler-concat-strings (x)
  (apply #'string-concat (tree-list x)))

;;;; TOPLEVEL

(defun transpiler-pass (tr forms)
(print
  (transpiler-concat-strings
    (transpiler-to-string tr
      (mapcar #'(lambda (x)
                  (funcall
				    (compose #'(lambda (x)
  								 (format t "Transpiler macro expansion...~%")
								 (expander-expand (transpiler-macro-expander tr) x))
						     #'(lambda (x)
  								  (format t "Argument expansion and finalizing expressions...~%")
								 (transpiler-finalize-sexprs tr x))
						     #'list
						     #'(lambda (x)
  								 (format t "Standard-macro expansion...~%")
								 (expander-expand (transpiler-std-macro-expander tr) x))
							 #'(lambda (x)
  								 (format t "Encapsulating...~%")
						         (transpiler-encapsulate-strings x))
#'print
							 #'(lambda (x)
  								 (format t "Expression expansion...~%")
						         (expression-expand x))
#'print
							 #'(lambda (x)
  								 (format t "Lamda expansion...~%")
						     	 (transpiler-lambda-expand x))
							 #'(lambda (x)
  								 (format t "Quote expansion...~%")
						         (backquote-expand x))
							 #'(lambda (x)
  								 (format t "Compiler-macro expansion...~%")
						     	 (compiler-macroexpand x))
							 #'(lambda (x)
  								 (format t "Macro expansion...~%")
						         (transpiler-macroexpand x))
						     #'(lambda (x)
  								 (format t "Standard-macro renaming...~%")
								 (expander-expand (transpiler-std-macro-renamer tr) x)))
				    x))
		      forms))))
)

(defun transpiler-wanted (tr verbose)
  (mapcan #'(lambda (x)
			  (with (fun (symbol-function x))
				(when (functionp fun)
				(if fun
					(or (and verbose (format t "Processing ~A~%" (list x)))
			  	    	(list (transpiler-pass tr `((defun ,x ,(function-arguments fun)
												      ,@(function-body fun))))))
					(and verbose (format t "Unknown function ~A~%" (list x)))))))
		  (append (transpiler-wanted-functions tr) *universe*)))

(defun transpiler-transpile (tr forms)
  (format t "Pass 1...~%")
  (transpiler-pass tr forms)
  (transpiler-wanted tr t)
  (format t "Pass 2...~%")
  (transpiler-concat-strings
	(list (transpiler-pass tr forms)
		  (transpiler-wanted tr t))))
