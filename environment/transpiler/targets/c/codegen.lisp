;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

;;;; GENERAL CODE GENERATION

(defun c-line (&rest x)
  `(,*c-indent*
    ,@x
	,*c-separator*))

(define-codegen-macro-definer define-c-macro *c-transpiler*)

(defun c-codegen-var-decl (name)
  `("treptr " ,(transpiler-symbol-string *c-transpiler* name)))

(defmacro define-c-binary (op repl-op)
  `(define-transpiler-binary *c-transpiler* ,op ,repl-op))

(defmacro define-c-infix (name)
  `(define-transpiler-infix *c-transpiler* ,name))

;;;; SYMBOL TRANSLATIONS

(transpiler-translate-symbol *c-transpiler* nil "treptr_nil")
(transpiler-translate-symbol *c-transpiler* t "treptr_t")

;;;; FUNCTIONS

(defun c-make-function-declaration (name args)
  (push (concat-stringtree
			"extern treptr "
			(transpiler-symbol-string *c-transpiler* name)
  	    	(parenthized-comma-separated-list
            	(mapcar #'c-codegen-var-decl args))
			";" (string (code-char 10)))
	    (transpiler-compiled-decls *c-transpiler*)))

(defun c-codegen-function (name x)
  (let args (argument-expand-names 'unnamed-c-function (lambda-args x))
    (c-make-function-declaration name args)
    `(,(code-char 10)
	  "treptr " ,name
	  ,@(parenthized-comma-separated-list (mapcar (fn `("treptr " ,_)) args))
	  ,(code-char 10)
	  "{" ,(code-char 10)
          ,@(lambda-body x)
	  "}" ,*c-newline*)))

(define-c-macro function (name &optional (x 'only-name))
  (if
	(eq 'only-name x)	name
    (atom x)			(error "codegen: arguments and body expected: ~A" x)
	(c-codegen-function name x)))

(define-c-macro %function-prologue (fi-sym)
  (with (fi (get-lambda-funinfo-by-sym fi-sym)
    	 num-vars (length (funinfo-env fi)))
	(if (< 0 num-vars)
		(c-codegen-function-prologue-for-local-variables fi num-vars)
		'(%transpiler-native ""))))

;;;; FUNCTION REFERENCE

;; Convert from lambda-expanded funref to one with lexical.
(define-c-macro %%funref (name fi-sym)
  (let fi (get-lambda-funinfo-by-sym fi-sym)
 	`("_trelist_get (" ,(c-compiled-symbol '%funref) ", "
		  "_trelist_get (" ,(c-compiled-symbol name)
		  				   "," 
						   ,(place-assign (place-expand-funref-lexical fi))
						"))")))

;;;; ASSIGNMENT

(defun codegen-%setq-place (dest val)
  (if (transpiler-obfuscated-nil? dest)
	  (if (codegen-expr? val)
		  '("")
	      '("(void) "))
	  `(,dest " = ")))

(defun codegen-%setq-value (val)
   (if (or (atom val)
		   (codegen-expr? val))
       val
       `(,val. ,@(parenthized-comma-separated-list .val))))

(define-c-macro %setq (dest val)
  (c-line `((%transpiler-native ,@(codegen-%setq-place dest val))
	                            ,(codegen-%setq-value val))))

(define-c-macro %setq-atom-value (dest val)
  `(%transpiler-native
       ,@(c-line "treatom_set_value (" (c-compiled-symbol dest)
				 					   " ," val ")")))

(define-c-macro %set-atom-fun (dest val)
  `(%transpiler-native ,dest "=" ,val ,*c-separator*))

;;;; STACK

(define-c-macro %stack (x)
  (c-stack x))

;;;; LEXICALS

(define-c-macro %vec (vec index)
  `("_TREVEC(" ,vec "," ,index ")"))

(define-c-macro %set-vec (vec index value)
  `("_TREVEC(" ,vec "," ,index ") = " ,value))

;;;; COMPARISON

(define-c-binary eq "=")

;;;; CONTROL FLOW

(define-c-macro %%tag (tag)
  `(%transpiler-native "l" ,tag ":" ,*c-newline*))
 
(define-c-macro %%vm-go (tag)
  (c-line "goto l" (transpiler-symbol-string *c-transpiler* tag)))

(define-c-macro %%vm-go-nil (val tag)
  `(,*c-indent* "if (" ,val " == treptr_nil)" ,(code-char 10)
	,*c-indent*
	,@(c-line "goto l" (transpiler-symbol-string *c-transpiler* tag))))

;;;; SYMBOLS

(define-c-macro %quote (x)
  (c-compiled-symbol x))

(define-c-macro symbol-function (x)
  `("treatom_get_function (" ,x ")"))

;;;; ARRAYS

(defun c-make-aref (arr idx)
  `("((treptr *) TREATOM_DETAIL(" ,arr "))["
	    ,(if (or (numberp idx)
				 (%transpiler-native? idx))
		  	 idx
			 `("(ulong)TRENUMBER_VAL(" ,idx ")"))
		"]"))

(define-c-macro aref (arr &rest idx)
  (if (= 1 (length idx))
	  (c-make-aref arr idx.)
	  `(trearray_builtin_aref ,arr ,@idx)))

(define-c-macro %set-aref (val arr &rest idx)
  (if (= 1 (length idx))
	  (append (c-make-aref arr idx.)
			  `("=" ,val))
	  `(trearray_builtin_set_aref ,val ,arr ,@idx)))

(define-c-macro make-array (size)
  (if (numberp size)
      `("trearray_make (" (%transpiler-native ,size) ")")
      `("trearray_get (_trelist_get (" ,size ", treptr_nil))")))
