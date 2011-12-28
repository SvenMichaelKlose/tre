;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

;;;; GENERAL CODE GENERATION

(defun c-line (&rest x)
  `(,*c-indent*
    ,@x
	,*c-separator*))

(define-codegen-macro-definer define-c-macro *c-transpiler*)

(defun c-codegen-var-decl (name)
  `("treptr " ,(transpiler-symbol-string *c-transpiler* name)))

;;;; SYMBOL TRANSLATIONS

(transpiler-translate-symbol *c-transpiler* nil "treptr_nil")
(transpiler-translate-symbol *c-transpiler* t "treptr_t")

;;;; FUNCTIONS

(defun c-make-function-declaration (name args)
  (push (concat-stringtree "extern treptr " (transpiler-symbol-string *c-transpiler* name)
  	    	               (parenthized-comma-separated-list (mapcar #'c-codegen-var-decl args))
			               ";" (string (code-char 10)))
	    (transpiler-compiled-decls *c-transpiler*)))

(defun c-codegen-function (name x)
  (let args (argument-expand-names 'unnamed-c-function (lambda-args x))
    (c-make-function-declaration name args)
    `(,(code-char 10)
	  "treptr " ,name " "
	  ,@(parenthized-comma-separated-list (mapcar (fn `("treptr " ,_)) args))
	  ,(code-char 10)
	  "{" ,(code-char 10)
          ,@(lambda-body x)
	  "}" ,*c-newline*)))

(defun %eq (&rest x)
  (apply #'eq x))

(defun %not (&rest x)
  (apply #'not x))

(define-c-macro eq (&rest x)
  `(%eq ,@x))

(define-c-macro function (name &optional (x 'only-name))
  (?
	(eq 'only-name x)	name
    (atom x)			(error "codegen: arguments and body expected: ~A" x)
	(c-codegen-function name x)))

(define-c-macro %function-prologue (fi-sym)
  (with (fi (get-funinfo-by-sym fi-sym)
    	 num-vars (length (funinfo-env fi)))
	(? (< 0 num-vars)
	   (c-codegen-function-prologue-for-local-variables fi num-vars)
	   '(%transpiler-native ""))))

;;;; FUNCTION REFERENCE

;; Convert from lambda-expanded funref to one with lexical.
(define-c-macro %%funref (name fi-sym)
  (let fi (get-funinfo-by-sym fi-sym)
 	`("_trelist_get (" ,(c-compiled-symbol '%funref) ", "
		  "_trelist_get (" ,(c-compiled-symbol name) "," ,(place-assign (place-expand-funref-lexical fi)) "))")))

;;;; ASSIGNMENT

(defun codegen-%setq-place (dest val)
  (? (transpiler-obfuscated-nil? dest)
	 (? (codegen-expr? val)
		'("")
	    '("(void) "))
	 `(,dest " = ")))

(defun codegen-%setq-value (val)
   (? (or (atom val)
		  (codegen-expr? val))
      val
      `(,val. ,@(parenthized-comma-separated-list .val))))

(define-c-macro %setq (dest val)
  (c-line `((%transpiler-native ,@(codegen-%setq-place dest val)) ,(codegen-%setq-value val))))

(define-c-macro %setq-atom-value (dest val)
  `(%transpiler-native "treatom_set_value (" ,(c-compiled-symbol dest) " ," ,val ")"))

(define-c-macro %set-atom-fun (dest val)
  `(%transpiler-native ,dest "=" ,val ,*c-separator*))

;;;; STACK

(define-c-macro %stack (x)
  (c-stack x))

;;;; LEXICALS

(define-c-macro %make-lexical-array (size)
  (c-make-array size))

(define-c-macro %vec (vec index)
  `("_TREVEC(" ,vec "," ,index ")"))

(define-c-macro %set-vec (vec index value)
  (c-line `(%transpiler-native "_TREVEC(" ,vec "," ,index ") = " ,(codegen-%setq-value value))))

;;;; CONTROL FLOW

(define-c-macro %%tag (tag)
  `(%transpiler-native "l" ,tag ":" ,*c-newline*))
 
(define-c-macro %%vm-go (tag)
  (c-line "goto l" (transpiler-symbol-string *c-transpiler* tag)))

(define-c-macro %%vm-go-nil (val tag)
  `(,*c-indent* "if (" ,val " == treptr_nil)" ,(code-char 10)
	,*c-indent* ,@(c-line "goto l" (transpiler-symbol-string *c-transpiler* tag))))

(define-c-macro %%vm-go-not-nil (val tag)
  `(,*c-indent* "if (" ,val " != treptr_nil)" ,(code-char 10)
	,*c-indent* ,@(c-line "goto l" (transpiler-symbol-string *c-transpiler* tag))))

;;;; SYMBOLS

(define-c-macro %quote (x)
  (c-compiled-symbol x))

(define-c-macro symbol-function (x)
  `("treatom_get_function (" ,x ")"))

;;;; ARRAYS

(defun c-make-aref (arr idx)
  `("((treptr *) TREATOM_DETAIL(" ,arr "))["
	    ,(? (or (number? idx)
				(%transpiler-native? idx))
		  	idx
			`("(ulong)TRENUMBER_VAL(" ,idx ")"))
		"]"))

(functional %immediate-aref %aref)

(define-c-macro %immediate-aref (arr idx)
  (c-make-aref arr idx))

(define-c-macro %aref (args)
  `(trearray_builtin_aref ,args))

(define-c-macro %immediate-set-aref (val arr idx)
  (append (c-make-aref arr idx)
		  `("=" ,val)))

(define-c-macro %set-aref (args)
  `(trearray_builtin_set_aref ,args))

(defun c-make-array (size)
  (? (number? size)
     `("trearray_make (" (%transpiler-native ,size) ")")
     `("trearray_get (_trelist_get (" ,size ", treptr_nil))")))

(define-c-macro make-array (size)
  (c-make-array size))
