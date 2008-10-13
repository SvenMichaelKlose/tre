;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

;;;; OPERATOR EXPANSION

(defmacro define-transpiler-infix (tr name)
  `(define-expander-macro ',(transpiler-macro-expander (eval tr)) ,name (x y)
	 `(%transpiler-native ,,x ,(string-downcase (string name)) " " ,,y)))

(defun transpiler-binary-expand (op args)
  (nconc (mapcan #'(lambda (x)
					 `(,x ,op))
				 (butlast args))
		 (last args)))

(defmacro define-transpiler-binary (tr op repl-op)
  `(define-expander-macro ',(transpiler-macro-expander (eval tr)) ,op (&rest args)
     `("(" ,,@(transpiler-binary-expand ,repl-op args) ")")))

;;;; ENCAPSULATION

(defun transpiler-encapsulate-strings (x)
  (if (atom x)
      (if (stringp x)
          (list '%transpiler-string x)
		  x)
	  (if (eq '%transpiler-native (car x))
		  x
		  (cons (transpiler-encapsulate-strings (car x))
		  		(transpiler-encapsulate-strings (cdr x))))))

;;;; EXPRESSION FINALIZATION

;; Add separators.
;;   Separators cannot be added later, because the expression bounds will
;;   disappear when everything is expanded to target-language strings in
;;   the next pass.
;; Make jump labels.
;; Remove (IDENTITY ~%RET)  expressions.
;; Add %VAR declarations for expex symbols.
(defun transpiler-finalize-sexprs (tr x)
  (when x
	(with (a          (car x)
		   separator  (transpiler-separator tr)
		   ret (transpiler-obfuscate tr '~%ret))
	  (if (eq a nil) ; ???
		  (transpiler-finalize-sexprs tr (cdr x))
	  	  (if (atom a) 
			  ; Make jump label.
		      (cons (funcall (transpiler-make-label tr) a)
		            (transpiler-finalize-sexprs tr (cdr x)))
              (if (and (%setq? a)
					   (is-lambda? (%setq-value a)))
			  	  ; Recurse into function.
	              (cons `(%var (%setq ,(%setq-place a)
										   ,(copy-recurse-into-lambda (%setq-value a)
										        #'((body)(transpiler-finalize-sexprs tr body)))))
			            (cons separator
						      (transpiler-finalize-sexprs tr (cdr x))))
	              (if (and (identity? a) (eq ret (second a)))
				  	  ; Ignore (IDENTITY ~%RET).
		              (transpiler-finalize-sexprs tr (cdr x))
				      ; Just copy with separator. Make return-value assignment if missing.
		              (cons (if (not (or (vm-jump? a)
									 	 (%setq? a)
									 	 (in? (car a) '%var '%transpiler-native)))
							    `(%setq ,ret ,a)
								; Add %VAR declaration for EXPEX symbols.
							    (if (and (%setq? a)
										 (expex-sym? (%setq-place a)))
									`(%var ,a)
									a))
						    (cons separator
							      (transpiler-finalize-sexprs tr (cdr x)))))))))))

;;;; TRANSPILER-MACRO EXPANDER
;;;;
;;;; Expands code-generating macros and converts expressions to C-style function calls.

;; Returns T for every %SETQ expression assigning the value of a function call.
(defun transpiler-macrop-funcall? (x)
  (and (consp x)
	   (%setq? x)
	   (consp (%setq-value x))
	   (not (stringp (first (%setq-value x))))
	   (not (in? (first (%setq-value x)) '%transpiler-string '%transpiler-native))))

(defun transpiler-macrocall-funcall (x)
  `("(" ,@(transpiler-binary-expand "," x) ")"))

(defun transpiler-macrocall (tr fun x)
  (with (m (cdr (assoc fun
					   (expander-macros (expander-get (transpiler-macro-expander tr))))))
    (if m
        (with (e (apply m x))
	       (if (transpiler-macrop-funcall? `(,fun ,@x))
				; Make C-style function call.
  		       `(,(first e) ,(second e) ,(first (third e)) ,@(transpiler-macrocall-funcall (cdr (third e))))
		       e))
		`(,fun ,@x))))

(defmacro define-transpiler-macro (tr name args body)
  `(define-expander-macro ',(transpiler-macro-expander (eval tr)) ,name ,args ,body))

;;;; POST PROCESSING

(defun transpiler-translate-symbol (tr from to)
  (acons! from to (transpiler-symbol-translations tr)))

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
			        (if (and (in=? c #\* #\-)
							 (cdr x))
						(cons (char-upcase (cadr x))
							  (convert-camel (cddr x)))
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

	(if (or (stringp s)
			(numberp s))
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
								   (if (in? (car e) '%transpiler-native '%no-expex)
									   (transpiler-to-string tr (cdr e))
									   e)))
				  ((stringp e) e)
				  (t		   (aif (assoc e (transpiler-symbol-translations tr))
								   (cdr !)
								   (string-concat (transpiler-symbol-string tr e) " ")))))
		   x))

;;;; TOPLEVEL

(defun transpiler-generate-code (tr forms)
  (with (str nil)
	(dolist (x forms str)
      (setf str
	    (string-concat str
			  (funcall
				(compose #'transpiler-concat-string-tree

						 #'(lambda (x)
            			     (transpiler-to-string tr x))

						 ; Expand expressions to strings.
						 #'(lambda (x)
							 (expander-expand (transpiler-macro-expander tr) x))

						 ; Expand top-level symbols, add expression separators.
					     #'(lambda (x)
							 (transpiler-finalize-sexprs tr x))

						 ; Wrap strings in %TRANSPILER-STRING expressions.
						 #'transpiler-encapsulate-strings

						 ; Obfuscate symbol-names.
						 #'(lambda (x)
							 (transpiler-obfuscate tr x))

						 #'(lambda (x)
							 (remove-if #'atom x)))
				 x))))))
