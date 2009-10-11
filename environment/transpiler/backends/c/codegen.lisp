;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Code generation

;;;; TRANSPILER-MACRO EXPANDER

(defmacro define-c-macro (&rest x)
  `(define-transpiler-macro *c-transpiler* ,@x))

(defun c-atomic-function (x)
  (compiled-function-name (second x)))

(define-c-macro function (name &optional (x 'only-name))
  (if (eq 'only-name x)
  	  `(treatom_get_function ,name)
  (if (atom x)
	  (error "codegen: arguments and body expected: ~A" x)
	  (with (args (argument-expand-names 'unnamed-c-function
			      		     	         (lambda-args x))
			 fi (get-lambda-funinfo x)
			 num-locals (length (funinfo-env fi)))
	    (push! (concat-stringtree
				   "extern treptr "
				   (transpiler-symbol-string *c-transpiler*
					   (compiled-function-name name))
				   "("
				   (if args
				       (concat-stringtree
	  	    		       (transpiler-binary-expand ","
	               			   (mapcar (fn `("treptr " ,(transpiler-symbol-string *c-transpiler* _)))
				    				   args)))
					  "")
				   ");" (string (code-char 10)))
			   (transpiler-compiled-decls *c-transpiler*))
        `(,(code-char 10)
		  "treptr " ,(compiled-function-name name) "("
	  	    ,@(transpiler-binary-expand ","
	                (mapcar (fn `("treptr " ,_))
						    args))
		  ")" ,(code-char 10)
	      "{" ,(code-char 10)
		     ,*c-indent* "treptr " ,'~%ret ,*c-separator*
			 ,@(when (< 0 num-locals)
			     `(,*c-indent* ,"treptr _local_array = trearray_make ("
							      ,num-locals
			  				      ");" ,*c-separator*
			       ,*c-indent* "tregc_push (_local_array)" ,*c-separator*
				   ; Keep registered syms from being garbage collected.
			       ,@(when (eq 'c-init name)
					   `(,*c-indent* "tregc_push (_local_array)" ,*c-separator*))
			 	   ,*c-indent*
				   ,"const treptr * _locals = (treptr *) "
									  	      "TREATOM_DETAIL(_local_array)"
											  ,*c-separator*))
             ,@(lambda-body x)
			 ,@(when (< 0 num-locals)
			     `(,*c-indent* "tregc_pop ();" ,*c-separator*))
;			 	   ,*c-indent* "treatom_remove (_local_array);" ,*c-separator*))
          	 (,*c-indent* "return " ,'~%ret ,*c-separator*)
	      "}" ,*c-newline*)))))

;; XXX same in js-transpiler
(defun codegen-%setq (dest val)
  `((%transpiler-native ,dest) "="
        ,(if (and (consp val)
                  (not (stringp val.))
                  (not (in? val.
                            '%transpiler-string '%transpiler-native)))
             `(,val. ,@(parenthized-comma-separated-list .val))
             val)))

(define-c-macro %setq (dest val)
  `(,*c-indent*
	,@(codegen-%setq dest val)
    ,*c-separator*))

(define-c-macro %setq-atom (dest val)
  `(%transpiler-native ,*c-indent* "treatom_set_value (" ,(c-compiled-symbol dest) " ,"
		,val
		")" ,*c-separator*))

;; XXX used for local functions
(define-c-macro %set-atom-fun (dest val)
  `(%transpiler-native ,dest "=" ,val))

;; XXX used to store argument definitions.
(define-c-macro %setq-atom-value (dest val)
  `(%transpiler-native ,*c-indent* "treatom_set_value (" ,(c-compiled-symbol dest) " ,"
		,val
		")" ,*c-separator*))

;  `(%transpiler-native "treatom_set_function (" ,dest " ,"
;		,val
;		")" ,*c-separator*))

(define-c-macro %var (name)
  `(%transpiler-native ,*c-indent* "treptr " ,name ,*c-separator*))

;;; TYPE PREDICATES

(defmacro define-c-infix (name)
  `(define-transpiler-infix *c-transpiler* ,name))

;(define-c-infix instanceof)

;;;; Symbol replacement definitions.

(transpiler-translate-symbol *c-transpiler* nil "treptr_nil")
(transpiler-translate-symbol *c-transpiler* t "treptr_t")

;;; Numbers, arithmetic and comparison.

(defmacro define-c-binary (op repl-op)
  `(define-transpiler-binary *c-transpiler* ,op ,repl-op))

(define-c-binary eq "=")

(define-c-macro vm-go (tag)
  `(,*c-indent* "goto l" ,(transpiler-symbol-string *c-transpiler* tag)
	,*c-separator*))

(define-c-macro vm-go-nil (val tag)
  `(,*c-indent* "if (" ,val " == treptr_nil)" ,(code-char 10)
	,*c-indent* ,*c-indent*
		"goto l" ,(transpiler-symbol-string *c-transpiler* tag)
	,*c-separator*))

(defun c-stack (x)
  `("_TRELOCAL(" ,x ")"))

(define-c-macro %stack (x)
  (c-stack x))

(define-c-macro quote (x)
  (c-compiled-symbol x))

(define-c-macro %quote (x)
  (c-compiled-symbol x))

(define-c-macro %set-vec (vec index value)
  `("_TREVEC(" ,vec "," ,index ") = " ,value))

(defun c-make-aref (arr idx)
  `("((treptr *) TREATOM_DETAIL(" ,arr "))["
	    ,(if (numberp idx)
		  	 idx
			 `("(ulong)TRENUMBER_VAL(" ,idx ")"))
		"]"))

(define-c-macro aref (arr &rest idx)
  (if (= 1 (length idx))
	  (c-make-aref arr idx.)
	  (prog1
	  `(trearray_builtin_aref ,val ,arr ,@idx)
		(print idx)
	  )))

(define-c-macro %set-aref (val arr &rest idx)
  (if (= 1 (length idx))
	  (append (c-make-aref arr idx.)
			  `("=" ,val))
	  (prog1
		`(trearray_builtin_set_aref ,val ,arr ,@idx)
		(print idx))))

(define-c-macro %vec (vec index)
  `("_TREVEC(" ,vec "," ,index ")"))

(define-c-macro cons (a d)
  `("_trelist_get (" ,a "," ,d ")"))

;; Convert from lambda-expanded funref to one with lexical.
(define-c-macro %%funref (name fi-sym)
  (let fi (get-lambda-funinfo-by-sym fi-sym)
 	 `("_trelist_get (" ,(c-compiled-symbol '%funref) ", "
		   "_trelist_get (" ,(c-compiled-symbol name) "," 
							,(place-assign (place-expand-funref-lexical fi))
						 "))")))

;; Lexical scope
(define-c-macro make-array (size)
  `("trearray_get (_trelist_get (" ,size ", treptr_nil))"))

(define-c-macro symbol-function (x)
  `("treatom_get_function (" ,x ")"))

(define-c-macro identity (x)
  x)

(define-c-macro %car (x)
  `("(" ,x " == treptr_nil ? treptr_nil : tre_lists[" ,x "].car)"))

(define-c-macro %cdr (x)
  `("(" ,x " == treptr_nil ? treptr_nil : tre_lists[" ,x "].cdr)"))

(define-c-macro %eq (a b)
  `("(" ,a " == " ,b " ? treptr_t : treptr_nil)"))

(define-c-macro %not (x)
  `("(" ,x " == treptr_nil ? treptr_t : treptr_nil)"))
