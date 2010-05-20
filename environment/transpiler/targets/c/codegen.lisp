;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Code generation

;; XXX fix macros instead?
(defun codegen-expr? (x)
  (and (consp x)
       (or (stringp x.)
       	   (in? x. '%transpiler-string '%transpiler-native))))

;;;; GENERAL CODE GENERATION

(defun c-line (&rest x)
  `(,*c-indent*
    ,@x
	,*c-separator*))

(defmacro define-c-macro (&rest x)
  `(define-transpiler-macro *c-transpiler* ,@x))

(defun c-atomic-function (x)
  (compiled-function-name (second x)))

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
  (push! (concat-stringtree
			 "extern treptr "
			 (transpiler-symbol-string *c-transpiler*
				 (compiled-function-name name))
  	    	 (parenthized-comma-separated-list
            	 (mapcar #'c-codegen-var-decl args))
			 ";" (string (code-char 10)))
		(transpiler-compiled-decls *c-transpiler*)))

(defun c-codegen-function (name x)
  (let args (argument-expand-names 'unnamed-c-function (lambda-args x))
    (c-make-function-declaration name args)
    `(,(code-char 10)
	  "treptr " ,(compiled-function-name name)
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

(defun c-codegen-function-prologue-for-local-variables (num-vars)
  `(,@(c-line "treptr _local_array = trearray_make (" num-vars ")")
    ,@(c-line "tregc_push (_local_array)")
    ,@(c-line "const treptr * _locals = (treptr *) TREATOM_DETAIL(_local_array)")))

(define-c-macro %function-prologue (fi-sym)
  (with (fi (get-lambda-funinfo-by-sym fi-sym)
    	 num-vars (length (funinfo-env fi)))
	(if (< 0 num-vars)
		(c-codegen-function-prologue-for-local-variables num-vars)
		'(%transpiler-native ""))))

(define-c-macro %function-return (fi-sym)
  (let fi (get-lambda-funinfo-by-sym fi-sym)
    `(%transpiler-native
         ,@(c-line "return " (place-assign (place-expand-0 fi '~%ret))))))

(define-c-macro %function-epilogue (fi-sym)
  (with (fi (get-lambda-funinfo-by-sym fi-sym)
    	 num-vars (length (funinfo-env fi)))
    `(,@(when (< 0 num-vars)
		  `(,(c-line "tregc_pop ()")))
      (%function-return ,fi-sym))))

;;;; FUNCTION REFERENCE

;; Convert from lambda-expanded funref to one with lexical.
(define-c-macro %%funref (name fi-sym)
  (let fi (get-lambda-funinfo-by-sym fi-sym)
 	`("_trelist_get (" ,(c-compiled-symbol '%funref) ", "
		  "_trelist_get (" ,(c-compiled-symbol name) "," 
						   ,(place-assign (place-expand-funref-lexical fi))
						"))")))

;;;; ASSIGNMENT

(defun codegen-%setq-0 (dest val)
  `((%transpiler-native 
	  ,@(if (transpiler-not dest)
		    (if (codegen-expr? val)
			  '("")
		      '("(void) "))
		    `(,dest " = ")))
    ,(if (or (atom val)
			 (codegen-expr? val))
         val
         `(,val. ,@(parenthized-comma-separated-list .val)))))

(defun codegen-%setq (dest val)
  (if (and (transpiler-not dest)
		   (atom val))
	  `(%transpiler-native "")
	  (codegen-%setq-0 dest val)))

(define-c-macro %setq (dest val)
  (c-line (codegen-%setq dest val)))

(defun c-codegen-set-atom-value (dest val)
  `(%transpiler-native
       ,@(c-line "treatom_set_value (" (c-compiled-symbol dest) " ," val ")")))

(define-c-macro %setq-atom (dest val)
  (c-codegen-set-atom-value dest val))

;; XXX used to store argument definitions.
(define-c-macro %setq-atom-value (dest val)
  (c-codegen-set-atom-value dest val))

(define-c-macro %set-atom-fun (dest val)
  `(%transpiler-native ,dest "=" ,val ,*c-separator*))
;  `(%transpiler-native ,*c-indent* "treatom_set_function (" ,dest " ,"
;		,val
;		")" ,*c-separator*))

;;;; VARIABLES

(defun c-stack (x)
  `("_TRELOCAL(" ,x ")"))

(define-c-macro %stack (x)
  (c-stack x))

;;;; LEXICALS

(define-c-macro %vec (vec index)
  `("_TREVEC(" ,vec "," ,index ")"))

(define-c-macro %set-vec (vec index value)
  `("_TREVEC(" ,vec "," ,index ") = " ,value))

;;;; COMPARISON

(define-c-binary eq "=")

(define-c-macro %eq (a b)
  `("TREPTR_TRUTH(" ,a " == " ,b ")"))

(define-c-macro %not (x)
  `("(" ,x " == treptr_nil ? treptr_t : treptr_nil)"))

;;;; CONTROL FLOW

(define-c-macro %%tag (tag)
  `(%transpiler-native "l" ,tag ":" ,*c-newline*))
 
(define-c-macro vm-go (tag)
  (c-line "goto l" (transpiler-symbol-string *c-transpiler* tag)))

(define-c-macro vm-go-nil (val tag)
  `(,*c-indent* "if (" ,val " == treptr_nil)" ,(code-char 10)
	,*c-indent*
	,@(c-line "goto l" (transpiler-symbol-string *c-transpiler* tag))))

;;;; SYMBOLS

(define-c-macro quote (x)
  (c-compiled-symbol x))

(define-c-macro %quote (x)
  (c-compiled-symbol x))

(define-c-macro symbol-function (x)
  `("treatom_get_function (" ,x ")"))

;;;; CONSES

(define-c-macro cons (a d)
  `("_trelist_get (" ,a "," ,d ")"))

(define-c-macro %car (x)
  `("(" ,x " == treptr_nil ? treptr_nil : tre_lists[" ,x "].car)"))

(define-c-macro %cdr (x)
  `("(" ,x " == treptr_nil ? treptr_nil : tre_lists[" ,x "].cdr)"))

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

;; Lexical scope
(define-c-macro make-array (size)
  (if (numberp size)
      `("trearray_make (" (%transpiler-native ,size) ")")
      `("trearray_get (_trelist_get (" ,size ", treptr_nil))")))

;;;; TYPE PREDICATES

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

;;;; MISCELLANEOUS

(define-c-macro identity (x)
  x)
