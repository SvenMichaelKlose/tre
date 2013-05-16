;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>


;;;; GENERAL CODE GENERATION

(defun c-line (&rest x)
  `(,*c-indent*
    ,@x
	,*c-separator*))

(define-codegen-macro-definer define-c-macro *c-transpiler*)

(defun c-codegen-var-decl (name)
  `("treptr " ,(transpiler-symbol-string *transpiler* name)))


;;;; SYMBOL TRANSLATIONS

(transpiler-translate-symbol *c-transpiler* nil "treptr_nil")
(transpiler-translate-symbol *c-transpiler* t "treptr_t")


;;;; FUNCTIONS

(defun c-make-function-declaration (name args)
  (push (concat-stringtree "extern treptr " (compiled-function-name-string *transpiler* name)
  	    	               " " (parenthized-comma-separated-list (mapcar #'c-codegen-var-decl args))
			               ";" *c-newline*)
	    (transpiler-compiled-decls *transpiler*)))

(defun c-codegen-function (name x)
  (with (fi   (get-funinfo name)
         args (argument-expand-names 'unnamed-c-function (funinfo-args fi)))
    (| fi (error "No funinfo for ~A.~%" name))
    (c-make-function-declaration name args)
    `(,*c-newline*
      "/*" ,*c-newline*
      "  argdef:   " ,(late-print (funinfo-argdef fi) nil) ,*c-newline*
      "  args:     " ,(late-print (funinfo-args fi) nil) ,*c-newline*
      "  env:      " ,(late-print (funinfo-vars fi) nil) ,*c-newline*
      "  lexical:  " ,(late-print (funinfo-lexical fi) nil) ,*c-newline*
      "  lexicals: " ,(late-print (funinfo-lexicals fi) nil) ,*c-newline*
      "*/" ,*c-newline*
	  "treptr " ,(compiled-function-name *transpiler* name) " "
	  ,@(parenthized-comma-separated-list (mapcar ^("treptr " ,_) args))
	  ,*c-newline*
	  "{" ,*c-newline*
          ,@(lambda-body x)
	  "}" ,*c-newline*)))

(define-c-macro %%closure (name)
  `("CONS (" ,(c-compiled-symbol '%closure) ", "
	    "CONS (" ,(c-compiled-symbol name) "," ,(codegen-closure-lexical name) "))"))

(defun %%%eq (&rest x)
  (apply #'eq x))

(define-c-macro function (name &optional (x 'only-name))
  (?
	(eq 'only-name x)	name
	(c-codegen-function name x)))

(define-c-macro %function-prologue (name)
  (c-codegen-function-prologue-for-local-variables (get-funinfo name)))


;;;; ASSIGNMENT

(defun codegen-%setq-place (dest val)
  (? dest
	 `(,dest " = ")
	 (? (codegen-expr? val)
		'("")
	    '("(void) "))))

(defun codegen-%setq-value (val)
   (? (| (atom val) (codegen-expr? val))
      val
      `(,val. ,@(parenthized-comma-separated-list .val))))

(define-c-macro %setq (dest val)
  (c-line `((%transpiler-native ,@(codegen-%setq-place dest val)) ,(codegen-%setq-value val))))

(define-c-macro %set-atom-fun (dest val)
  `(%transpiler-native ,dest "=" ,val ,*c-separator*))


;;;; ARGUMENT EXPANSION CONSING

(define-c-macro %%%cons (a d)
  `(%transpiler-native "CONS(" ,a ", " ,d ")"))


;;;; STACK


(define-c-macro %stack (x)
  (c-stack x))


;;;; LEXICALS

(defun c-make-array (size)
  (? (number? size)
     `("trearray_make (" (%transpiler-native ,size) ")")
     `("trearray_get (CONS (" ,size ", treptr_nil))")))

(define-c-macro %make-lexical-array (size)
  (c-make-array size))

(define-c-macro %vec (vec index)
  `("_TREVEC(" ,vec "," ,index ")"))

(define-c-macro %set-vec (vec index value)
  (c-line `(%transpiler-native "_TREVEC(" ,vec "," ,index ") = " ,(codegen-%setq-value value))))


;;;; CONTROL FLOW

(define-c-macro %%tag (tag)
  `(%transpiler-native "l" ,tag ":" ,*c-newline*))
 
(define-c-macro %%go (tag)
  (c-line `(%transpiler-native "goto l" ,tag)))

(define-c-macro %%go-nil (tag val)
  `(,*c-indent* "if (" ,val " == treptr_nil)" ,*c-newline*
	,*c-indent* ,@(c-line `(%transpiler-native "goto l" ,tag))))


;;;; SYMBOLS

(define-c-macro %quote (x)
  (c-compiled-symbol x))

(define-c-macro symbol-function (x)
  `("treatom_get_function (" ,x ")"))

(define-c-macro =-symbol-value (v x)
  `("TRESYMBOL_VALUE(" ,x ")=" ,v))


;;;; ARRAYS

(define-c-macro make-array (&rest sizes)
  (? (== 1 (length sizes))
     (c-make-array sizes.)
     `(trearray_builtin_make ,(compiled-list sizes)))]

(defun c-make-aref (arr idx)
  `("TREARRAY_VALUES(" ,arr ")["
	    ,(? (| (number? idx)
               (%transpiler-native? idx))
		  	idx
			`("(size_t)TRENUMBER_VAL(" ,idx ")"))
		"]"))

(define-c-macro %immediate-aref (arr idx)
  (c-make-aref arr idx))

(define-c-macro %immediate-set-aref (val arr idx)
  (+ (c-make-aref arr idx) `("=" ,val)))
