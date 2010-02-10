;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Code generation

(defmacro define-c-macro (&rest x)
  `(define-transpiler-macro *c-transpiler* ,@x))

(defun c-atomic-function (x)
  (compiled-function-name (second x)))

(defun c-make-function-declaration (name args)
  (push! (concat-stringtree
			 "extern treptr "
			 (transpiler-symbol-string *c-transpiler*
				 (compiled-function-name name))
			 (concat-stringtree
  	    	     (parenthized-comma-separated-list
            		 (mapcar (fn `("treptr " ,(transpiler-symbol-string *c-transpiler* _)))
			   				 args)))
			 ";" (string (code-char 10)))
		(transpiler-compiled-decls *c-transpiler*)))

(define-c-macro function (name &optional (x 'only-name))
  (if
	(eq 'only-name x)	name
    (atom x)			(error "codegen: arguments and body expected: ~A" x)
	(let args (argument-expand-names 'unnamed-c-function (lambda-args x))
	  (c-make-function-declaration name args)
      `(,(code-char 10)
		"treptr " ,(compiled-function-name name)
	  	  ,@(parenthized-comma-separated-list (mapcar (fn `("treptr " ,_)) args))
		,(code-char 10)
	    "{" ,(code-char 10)
           ,@(lambda-body x)
	    "}" ,*c-newline*))))

(define-c-macro %function-prologue (fi-sym)
  (with (fi (get-lambda-funinfo-by-sym fi-sym)
    	 num-vars (length (funinfo-env fi)))
	(if (< 0 num-vars)
        `(,*c-indent* ,"treptr _local_array = trearray_make (" ,num-vars ")" ,*c-separator*
          ,*c-indent* "tregc_push (_local_array)" ,*c-separator*
          ,*c-indent* ,"const treptr * _locals = (treptr *) " "TREATOM_DETAIL(_local_array)" ,*c-separator*)
		'(%transpiler-native ""))))

(define-c-macro %function-return (fi-sym)
  (let fi (get-lambda-funinfo-by-sym fi-sym)
    `(%transpiler-native ,*c-indent* "return " ,(place-assign (place-expand-0 fi '~%ret)) ,*c-separator*)))

(define-c-macro %function-epilogue (fi-sym)
  (with (fi (get-lambda-funinfo-by-sym fi-sym)
    	 num-vars (length (funinfo-env fi)))
    `(,@(when (< 0 num-vars)
		  `((,*c-indent* "tregc_pop ()" ,*c-separator*)))
      (%function-return ,fi-sym))))

;; XXX fix macros instead?
(defun codegen-expr? (x)
  (and (consp x)
       (or (stringp x.)
       	   (in? x. '%transpiler-string '%transpiler-native))))

(defun codegen-%setq (dest val)
  `((%transpiler-native 
	  ,@(if (eq dest (transpiler-obfuscate-symbol *c-transpiler* nil))
		    (if (codegen-expr? val)
			  '("")
		      '("(void) "))
		    `(,dest " = ")))
    ,(if (or (atom val)
			 (codegen-expr? val))
         val
         `(,val. ,@(parenthized-comma-separated-list .val)))))

(define-c-macro %setq (dest val)
  `(,*c-indent*
	,@(codegen-%setq dest val)
    ,*c-separator*))

(define-c-macro %setq-atom (dest val)
  `(%transpiler-native ,*c-indent* "treatom_set_value (" ,(c-compiled-symbol dest) " ,"
		,val
		")" ,*c-separator*))

(define-c-macro %set-atom-fun (dest val)
  `(%transpiler-native ,dest "=" ,val ,*c-separator*))
;  `(%transpiler-native ,*c-indent* "treatom_set_function (" ,dest " ,"
;		,val
;		")" ,*c-separator*))

;; XXX used to store argument definitions.
(define-c-macro %setq-atom-value (dest val)
  `(%transpiler-native ,*c-indent* "treatom_set_value (" ,(c-compiled-symbol dest) " ,"
		,val
		")" ,*c-separator*))

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
	    ,(if (or (numberp idx)
				 (%transpiler-native? idx))
		  	 idx
			 `("(ulong)TRENUMBER_VAL(" ,idx ")"))
		"]"))

(define-c-macro aref (arr &rest idx)
  (if (= 1 (length idx))
	  (c-make-aref arr idx.)
	  `(trearray_builtin_aref ,val ,arr ,@idx)))

(define-c-macro %set-aref (val arr &rest idx)
  (if (= 1 (length idx))
	  (append (c-make-aref arr idx.)
			  `("=" ,val))
	  `(trearray_builtin_set_aref ,val ,arr ,@idx)))

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
  (if (numberp size)
      `("trearray_make (" (%transpiler-native ,size) ")")
      `("trearray_get (_trelist_get (" ,size ", treptr_nil))")))

(define-c-macro symbol-function (x)
  `("treatom_get_function (" ,x ")"))

(define-c-macro identity (x)
  x)

(define-c-macro %car (x)
  `("(" ,x " == treptr_nil ? treptr_nil : tre_lists[" ,x "].car)"))

(define-c-macro %cdr (x)
  `("(" ,x " == treptr_nil ? treptr_nil : tre_lists[" ,x "].cdr)"))

(define-c-macro %eq (a b)
  `("TREPTR_TRUTH(" ,a " == " ,b ")"))

(define-c-macro %not (x)
  `("(" ,x " == treptr_nil ? treptr_t : treptr_nil)"))

(mapcan-macro _
	'((consp "CONS")
	  (atom  "ATOM")
	  (numberp  "NUMBER")
	  (stringp  "STRING")
	  (arrayp  "ARRAY")
	  (functionp  "FUNCTION")
	  (builtinp   "BUILTIN"))
  `((define-c-macro ,($ '% _.) (x)
      `(,(+ "TREPTR_TRUTH(TREPTR_IS_" ._.) "(" ,,x "))"))))

;#define TREPTR_IS_VARIABLE(ptr) (TREPTR_TYPE(ptr) == TRETYPE_VARIABLE)
;#define TREPTR_IS_SYMBOL(ptr)   (TREPTR_IS_VARIABLE(ptr) && TREATOM_VALUE(ptr) == ptr)
;macro
