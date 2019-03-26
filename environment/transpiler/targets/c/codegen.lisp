;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun c-line (&rest x)
  `(,*c-indent* ,@x ,*c-separator*))

(define-codegen-macro-definer define-c-macro *c-transpiler*)

(defun c-codegen-var-decl (name)
  `("treptr " ,(obfuscated-identifier name)))


;;;; SYMBOL TRANSLATIONS

(transpiler-translate-symbol *c-transpiler* nil "treptr_nil")
(transpiler-translate-symbol *c-transpiler* t   "treptr_t")


;;;; FUNCTIONS

(defun c-arguments (fi)
  (c-list (mapcar #'c-codegen-var-decl (funinfo-args fi))))

(defun c-make-function-declaration (name args)
  (push (concat-stringtree "extern treptr " (compiled-function-name-string name)
  	    	               " "
                           (c-arguments (get-funinfo name))
			               ";" *newline*)
	    (transpiler-compiled-decls *transpiler*)))

(defun c-codegen-function (name x)
  (with (fi    (get-funinfo name)
         args  (funinfo-args fi))
    (| fi (error "No funinfo for ~A." name))
    (c-make-function-declaration name args)
    `(,*newline*
      ,(funinfo-comment fi)
	  "treptr " ,(compiled-function-name name) " "
	  ,@(c-list (mapcar ^("treptr " ,_) args))
	  ,*newline*
	  "{" ,*newline*
          ,@(lambda-body x)
	  "}" ,*newline*)))

(define-c-macro function (name &optional (x 'only-name))
  (? (eq 'only-name x)
     name
	(c-codegen-function name x)))

(define-c-macro %function-prologue (name)
  (let fi (get-funinfo name)
    `(,@(c-line "treptr __ret")
      ,@(alet (length (funinfo-vars fi))
          `(,@(& (< 1 !)
	             `(("    int __c; for (__c = " ,! "; __c > 0; __c--)")))
            ,@(& (< 0 !)
                 (c-line " *--trestack_ptr = treptr_nil"))))
      ,@(copy-arguments-to-vars fi))))

(define-c-macro %function-epilogue (name)
  (let fi (get-funinfo name)
    `((%= "__ret" ,(place-assign (place-expand-0 fi '~%ret)))
      ,@(alet (length (funinfo-vars fi))
          (& (< 0 !)
             `(,(c-line "trestack_ptr += " !))))
      (%function-return ,name))))

(define-c-macro %function-return (name)
  `(%%native ,@(c-line "return __ret")))

(define-c-macro %%closure (name)
  (alet (get-funinfo name)
    (? (funinfo-scope-arg !)
       `("CONS (" ,(c-compiled-symbol '%closure) ", "
                "CONS (" ,(c-compiled-symbol name) "," ,(codegen-closure-scope name) "))")
       `("TRESYMBOL_FUN(" ,(c-compiled-symbol name) ")"))))


;;;; ASSIGNMENT

(defun codegen-%=-place (dest val)
  (? dest
	 `(,dest " = ")
	 (? (codegen-expr? val)
		'("")
	    '("(void) "))))

(defun codegen-%=-value (x)
   (? (atom|codegen-expr? x)
      x
      `(,x. ,@(c-list .x))))

(define-c-macro %= (dest val)
  (c-line `((%%native ,@(codegen-%=-place dest val)) ,(codegen-%=-value val))))

(define-c-macro %set-atom-fun (dest val)
  `(%%native ,dest "=" ,val ,*c-separator*))


;;;; STACK

(define-c-macro %stack (x)
  `("trestack_ptr[" ,x "]"))


;;;; LEXICALS

(defun c-make-array (size)
  (? (number? size)
     `("trearray_make (" (%%native ,size) ")")
     `("trearray_get (CONS (" ,size ", treptr_nil))")))

(define-c-macro %make-scope (size)
  (c-make-array size))

(define-c-macro %vec (vec index)
  `("_TREVEC(" ,vec "," ,index ")"))

(define-c-macro %set-vec (vec index value)
  (c-line `(%%native "_TREVEC(" ,vec "," ,index ") = " ,(codegen-%=-value value))))


;;;; CONTROL FLOW

(define-c-macro %%tag (tag)
  `(%%native "l" ,tag ":" ,*newline*))
 
(define-c-macro %%go (tag)
  (c-line `(%%native "goto l" ,tag)))

(define-c-macro %%go-nil (tag x)
  `(,*c-indent* "if (" ,x " == treptr_nil)" ,*newline*
	,*c-indent* ,@(c-line `(%%native "goto l" ,tag))))

(define-c-macro %%go-not-nil (tag x)
  `(,*c-indent* "if (" ,x " != treptr_nil)" ,*newline*
	,*c-indent* ,@(c-line `(%%native "goto l" ,tag))))

(define-c-macro return-from (block-name x)
  (error "Cannot return from unknown BLOCK ~A." block-name))

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


;;;; GLOBAL VARIABLES

(define-c-macro %global (x)
  `("TRESYMBOL_VALUE(" ,(c-compiled-symbol x) ")"))


;;;; EXCEPTIONS

(define-c-macro %catch-enter ()
  "(setjmp (catchers[current_catcher].jmp) ? treptr_t : treptr_nil)")
