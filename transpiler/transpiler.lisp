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
  std-macro-expander
  macro-expander
  separator
  (function-args nil)
  (wanted-functions nil)
  (identifier-char? nil)
  (symbol-translations nil))

(defun create-transpiler (&rest args)
  (with (tr (apply #'make-transpiler args))
    (define-expander (transpiler-std-macro-expander tr))
	(define-expander (transpiler-macro-expander tr)
					 nil nil
					 nil #'(lambda (fun x)
							 (transpiler-macrocall tr fun x)))
	tr))

(defun transpiler-translate-symbol (tr from to)
  (acons! from to (transpiler-symbol-translations tr)))

;;;; SLOT GETTER GENERATION

(defun transpiler-make-slot-getters (x)
  (maptree #'((x)
				(if (and (atom x) (not (or (numberp x) (stringp x))))
				    (with (sl (string-list (symbol-name x))
					       p (position #\. sl :test #'=))
				      (if p
					      `(get-slot ,(make-symbol (list-string (subseq sl (1+ p))))
								     ,(make-symbol (list-string (subseq sl 0 p))))
					      x))
					x))
		  x))

;;;; OPERATOR EXPANSION

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

;;;; STANDARD MACRO EXPANSION

(defun transpiler-macroexpand (x)
  (repeat-while-changes #'((x) (*macroexpand-hook* x)) x))

;;;; EXPANSION OF ALTERNATE STANDARD MACROS

(defmacro define-transpiler-std-macro (tr name args body)
  (with (tre (eval tr))
    `(define-expander-macro ,(transpiler-std-macro-expander tre)
							  ,name
							  ,args
	   ,body)))

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

;;;; ENCAPSULATION

(defun transpiler-encapsulate-strings (form)
  (maptree #'((x)
               (if (stringp x)
                   (list '%transpiler-string x)
                   x))
           form))

;;;; EXPRESSION FINALIZATION

(defun transpiler-finalize-sexprs (tr x)
  (when x
	(with (e          (car x)
		   separator  (transpiler-separator tr))
	  (if (eq e nil)
		  (transpiler-finalize-sexprs tr (cdr x))
	  	  (if (atom e) ; Jump label.
		      (cons (string-concat (transpiler-symbol-string tr e) (format nil ":~%"))
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
							      (transpiler-finalize-sexprs tr (cdr x)))))))))))

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
				; Make C-style function call.
  		       `(,(first e) ,(second e) ,(first (third e)) ,@(transpiler-macrocall-funcall (cdr (third e))))
		       e))
		`(,fun ,@x))))

(defmacro define-transpiler-macro (tr name args body)
  `(define-expander-macro ,(transpiler-macro-expander (eval tr)) ,name ,args ,body))

;;;; POST PROCESSING

(defun transpiler-special-char? (tr x)
  (not (funcall (transpiler-identifier-char? tr) x)))

(defun transpiler-symbol-string (tr s)
  (with (encapsulate-char
		   #'((x)
				(string-list (string-concat "T" (format nil "~A" (char-code x)))))
				
		 convert-camel
		   #'((x)
				(when x
			      (with (c (char-downcase (car x)))
			        (if (or (in=? c #\*)
							(and (= #\- c) (cdr x)))
				        (when (cdr x)
						  (cons (char-upcase (cadr x))
							    (convert-camel (cddr x))))
					    (cons c (convert-camel (cdr x)))))))

		 convert-special2
		   #'((x)
				(when x
			      (with (c (car x))
				    (if (transpiler-special-char? tr c)
					    (append (encapsulate-char c)
								(convert-special2 (cdr x)))
					    (cons c (convert-special2 (cdr x)))))))

		 convert-special
		   #'((x)
				(when x
			      (with (c (car x))
					; Encapsulate initial char if it's a digit.
				    (if (digit-char-p c)
					    (append (encapsulate-char c)
							    (convert-special2 (cdr x)))
						(convert-special2 x)))))

		 str (string s)
	     l (length str))

	(if (numberp s)
		str
        (list-string
	      (convert-special
            (if (and (< 2 (length str)) ; Make *GLOBAL* upcase.
			         (= (elt str 0) #\*)
			         (= (elt str (1- l)) #\*))
		        (remove-if #'((x)
						        (= x #\-))
					       (string-list (string-upcase (subseq str 1 (1- l)))))
    	        (convert-camel (string-list str))))))))

(defun transpiler-to-string (tr x)
  (maptree #'((e)
				(cond
				  ((consp e)   (if (eq (car e) '%transpiler-string)
								   (string-concat "\"" (cadr e) "\"")
									(if (eq (car e) '%transpiler-native)
										(transpiler-to-string tr (cdr e))
										e)))
				  ((stringp e) e)
				  (t		   (aif (assoc e (transpiler-symbol-translations tr))
								   (cdr !)
								   (string-concat (transpiler-symbol-string tr e) " ")))))
		   x))

(defun transpiler-concat-strings (x)
  (apply #'string-concat (tree-list x)))

;;;; TOPLEVEL

(defun transpiler-pass1 (tr forms)
  (dolist (x forms)
    (funcall
	  (compose #'(lambda (x)
  				   (format t "Expression expansion...~%")
		           (expression-expand x))
				 #'(lambda (x)
  				   (format t "Lambda expansion...~%")
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
			     #'list
			     #'(lambda (x)
  				   (format t "Standard-macro expansion...~%")
				   (expander-expand (transpiler-std-macro-expander tr) x)))
	    x)))

(defun transpiler-pass2 (tr forms)
  (print
  (transpiler-concat-strings
    (transpiler-to-string tr
      (mapcar #'(lambda (x)
                  (funcall
				    (compose #'(lambda (x)
  								 (format t "Transpiler macro expansion...~%")
								 (expander-expand (transpiler-macro-expander tr) x))
						     #'(lambda (x)
  								  (format t "Finalizing expressions...~%")
								 (transpiler-finalize-sexprs tr x))
							 #'(lambda (x)
  								 (format t "Encapsulating strings...~%")
						         (transpiler-encapsulate-strings x))
							 #'(lambda (x)
  								 (format t "Expression expansion...~%")
						         (expression-expand x))
							 #'(lambda (x)
  								 (format t "Lambda expansion...~%")
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
						     #'list
							 #'(lambda (x)
  								 (format t "Generating slot getters...~%")
						         (transpiler-make-slot-getters x))
						     #'(lambda (x)
  								 (format t "Standard-macro expansion...~%")
								 (expander-expand (transpiler-std-macro-expander tr) x))
)
				    x))
		      forms)))))

(defun transpiler-wanted (tr pass verbose)
  (with (out nil)
    (dolist (x (transpiler-wanted-functions tr)
			 (reverse out))
	  (with (fun (symbol-function x))
		     (when (functionp fun)
			   (if fun
				   (or (and verbose
						    (format t "~%Processing ~A" (list x)))
			  	       (push (funcall pass tr `((defun ,x ,(function-arguments fun)
											      ,@(function-body fun))))
							 out))
				  (and verbose (format t "Unknown function ~A" (list x)))))))))

(defun transpiler-transpile (tr forms name)
  ;(format t "### Pass 1...~%")
  ;(transpiler-pass1 tr forms)
  ;(transpiler-wanted tr #'transpiler-pass1 t)

  (format t "### Pass 2...~%")
  (with (src (transpiler-concat-strings
			   (list (transpiler-pass2 tr forms)
		  		   (transpiler-wanted tr #'transpiler-pass2 t))))
  (format t "### Emitting code...~%")
	(with-open-file f (open name :direction 'output)
	  (format f "// TRE transpiler output~%")
	  (format f "// http://www.copei.de~%")
	  (format f "~A" src))))
