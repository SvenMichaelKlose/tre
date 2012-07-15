;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

;;;; GENERAL CODE GENERATION

(defun bc-line (&rest x)
  `(,*bc-indent*
    ,@x
	,*bc-separator*))

(define-codegen-macro-definer define-bc-macro *bc-transpiler*)

;;;; SYMBOL TRANSLATIONS

(transpiler-translate-symbol *bc-transpiler* nil "treptr_nil")
(transpiler-translate-symbol *bc-transpiler* t "treptr_t")

;;;; FUNCTIONS

(define-bc-macro function (name &optional (x 'only-name))
  (?
	(eq 'only-name x)	name
    (atom x)			(error "codegen: arguments and body expected: ~A" x)
    `(%%%bc-fun ,name ,(argument-expand-names 'unnamed-bc-function (lambda-args x))
      ,@(lambda-body x))))

(define-bc-macro %function-prologue (fi-sym)
  (bc-codegen-function-prologue-for-local-variables (get-funinfo-by-sym fi-sym)))

;;;; FUNCTION REFERENCE

;; Convert from lambda-expanded funref to one with lexical.
(define-bc-macro %%funref (name fi-sym)
  (let fi (get-funinfo-by-sym fi-sym)
 	`("_trelist_get (" ,(bc-compiled-symbol '%funref) ", "
		  "_trelist_get (" ,(bc-compiled-symbol name) "," ,(place-assign (place-expand-funref-lexical fi)) "))")))

;;;; ASSIGNMENT

(define-bc-macro %setq (dest val)
  (bc-line `((%transpiler-native ,@(codegen-%setq-place dest val)) ,(codegen-%setq-value val))))

(define-bc-macro %setq-atom-value (dest val)
  `(%transpiler-native "treatom_set_value (" ,(bc-compiled-symbol dest) " ," ,val ")"))

(define-bc-macro %set-atom-fun (dest val)
  `(%transpiler-native ,dest "=" ,val ,*bc-separator*))

;;;; STACK

(define-bc-macro %stack (x)
  (bc-stack x))

;;;; LEXICALS

(define-bc-macro %make-lexical-array (size)
  (bc-make-array size))

(define-bc-macro %vec (vec index)
  `("_TREVEC(" ,vec "," ,index ")"))

(define-bc-macro %set-vec (vec index value)
  (bc-line `(%transpiler-native "_TREVEC(" ,vec "," ,index ") = " ,(codegen-%setq-value value))))

;;;; CONTROL FLOW

(define-bc-macro %%tag (tag)
  `(%transpiler-native "l" ,tag ":" ,*bc-newline*))
 
(define-bc-macro %%vm-go (tag)
  (bc-line "goto l" (transpiler-symbol-string *current-transpiler* tag)))

(define-bc-macro %%vm-go-nil (val tag)
  `(,*bc-indent* "if (" ,val " == treptr_nil)" ,(code-char 10)
	,*bc-indent* ,@(bc-line "goto l" (transpiler-symbol-string *current-transpiler* tag))))

(define-bc-macro %%vm-go-not-nil (val tag)
  `(,*bc-indent* "if (" ,val " != treptr_nil)" ,(code-char 10)
	,*bc-indent* ,@(bc-line "goto l" (transpiler-symbol-string *current-transpiler* tag))))

;;;; SYMBOLS

(define-bc-macro %quote (x)
  (bc-compiled-symbol x))

(define-bc-macro symbol-function (x)
  `("treatom_get_function (" ,x ")"))

;;;; ARRAYS

(defun bc-make-aref (arr idx)
  `("((treptr *) TREATOM_DETAIL(" ,arr "))["
	    ,(? (| (number? idx) (%transpiler-native? idx))
		  	idx
			`("(ulong)TRENUMBER_VAL(" ,idx ")"))
		"]"))

(functional %immediate-aref %aref)

(define-bc-macro %immediate-aref (arr idx)
  (bc-make-aref arr idx))

(define-bc-macro %aref (args)
  `(trearray_builtin_aref ,args))

(define-bc-macro %immediate-set-aref (val arr idx)
  (append (bc-make-aref arr idx)
		  `("=" ,val)))

(define-bc-macro %set-aref (args)
  `(trearray_builtin_set_aref ,args))

(defun bc-make-array (size)
  (? (number? size)
     `("trearray_make (" (%transpiler-native ,size) ")")
     `("trearray_get (_trelist_get (" ,size ", treptr_nil))")))

(define-bc-macro make-array (size)
  (bc-make-array size))
