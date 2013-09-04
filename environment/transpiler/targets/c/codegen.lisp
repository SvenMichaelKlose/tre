;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun c-line (&rest x)
  `(,*c-indent* ,@x ,*c-separator*))

(define-codegen-macro-definer define-c-macro *c-transpiler*)

(defun c-codegen-var-decl (name)
  `("treptr " ,(transpiler-symbol-string *transpiler* name)))


;;;; SYMBOL TRANSLATIONS

(transpiler-translate-symbol *c-transpiler* nil "treptr_nil")
(transpiler-translate-symbol *c-transpiler* t   "treptr_t")


;;;; FUNCTIONS

(defun c-make-function-declaration (name args)
  (push (concat-stringtree "extern treptr " (compiled-function-name-string *transpiler* name)
  	    	               " " (parenthized-comma-separated-list (mapcar #'c-codegen-var-decl args))
			               ";" *c-newline*)
	    (transpiler-compiled-decls *transpiler*)))

(defun c-codegen-function (name x)
  (with (fi   (get-funinfo name)
         args (argument-expand-names 'unnamed-c-function (funinfo-args fi)))
    (| fi (error "No funinfo for ~A." name))
    (c-make-function-declaration name args)
    `(,*c-newline*
      ,(funinfo-comment fi)
	  "treptr " ,(compiled-function-name *transpiler* name) " "
	  ,@(parenthized-comma-separated-list (mapcar ^("treptr " ,_) args))
	  ,*c-newline*
	  "{" ,*c-newline*
          ,@(lambda-body x)
	  "}" ,*c-newline*)))

(define-c-macro %%closure (name)
  `("CONS (" ,(c-compiled-symbol '%closure) ", "
	       "CONS (" ,(c-compiled-symbol name) "," ,(codegen-closure-lexical name) "))"))

(define-c-macro function (name &optional (x 'only-name))
  (? (eq 'only-name x)
     name
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

(defun codegen-%setq-value (x)
   (? (atom|codegen-expr? x)
      x
      `(,x. ,@(parenthized-comma-separated-list .x))))

(define-c-macro %setq (dest val)
  (c-line `((%%native ,@(codegen-%setq-place dest val)) ,(codegen-%setq-value val))))

(define-c-macro %set-atom-fun (dest val)
  `(%%native ,dest "=" ,val ,*c-separator*))


;;;; STACK

(define-c-macro %stack (x)
  (c-stack x))


;;;; LEXICALS

(defun c-make-array (size)
  (? (number? size)
     `("trearray_make (" (%%native ,size) ")")
     `("trearray_get (CONS (" ,size ", treptr_nil))")))

(define-c-macro %make-lexical-array (size)
  (c-make-array size))

(define-c-macro %vec (vec index)
  `("_TREVEC(" ,vec "," ,index ")"))

(define-c-macro %set-vec (vec index value)
  (c-line `(%%native "_TREVEC(" ,vec "," ,index ") = " ,(codegen-%setq-value value))))


;;;; CONTROL FLOW

(define-c-macro %%tag (tag)
  `(%%native "l" ,tag ":" ,*c-newline*))
 
(define-c-macro %%go (tag)
  (c-line `(%%native "goto l" ,tag)))

(define-c-macro %%go-nil (tag x)
  `(,*c-indent* "if (" ,x " == treptr_nil)" ,*c-newline*
	,*c-indent* ,@(c-line `(%%native "goto l" ,tag))))


;;;; SYMBOLS

(define-c-macro %quote (x)
  (c-compiled-symbol x))


;;;; ARRAYS

(defun c-make-aref (arr idx)
  `("TREARRAY_VALUES(" ,arr ")["
	    ,(? (| (number? idx)
               (%%native? idx))
		  	idx
			`("(size_t)TRENUMBER_VAL(" ,idx ")"))
		"]"))

(define-c-macro %immediate-aref (arr idx)
  (c-make-aref arr idx))

(define-c-macro %immediate-=-aref (val arr idx)
  (+ (c-make-aref arr idx) `("=" ,val)))
