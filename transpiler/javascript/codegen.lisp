;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Code generation

;;;; TRANSPILER-MACRO EXPANDER

(defmacro define-js-macro (name args body)
  `(define-transpiler-macro *js-transpiler* ,name ,args ,body))

(define-js-macro function (x)
  (if (atom x)
	  x
      (with (args (argument-expand 'unnamed-js-function (lambda-args x) nil nil)
			 ret (transpiler-obfuscate *js-transpiler* '~%ret))
        `("function (" ,@(transpiler-binary-expand
				            ","
						    args) ")"
	      ,(code-char 10)
	        "{var " ,ret ,*js-separator*
	        "var _ = 0" ,*js-separator*
	        "while (1) {"
	          "switch (_) {case 0:"
                ,@(lambda-body x)
              ("}return " ,ret ,*js-separator*)
	        "}}"))))

(define-js-macro %setq (dest val)
  `((%transpiler-native ,dest) "=" ,val))

(define-js-macro %var (name)
  `(%transpiler-native "var " ,name))

;;; TYPE PREDICATES

(defmacro define-js-infix (name)
  `(define-transpiler-infix *js-transpiler* ,name))

(define-js-infix instanceof)

;;;; Symbol replacement definitions.

(transpiler-translate-symbol *js-transpiler* nil "null")
(transpiler-translate-symbol *js-transpiler* t "true")

;;; Numbers, arithmetic and comparison.

(defmacro define-js-binary (op repl-op)
  `(define-transpiler-binary *js-transpiler* ,op ,repl-op))

(define-js-binary + "+")
(define-js-binary - "-")
(define-js-binary / "/")
(define-js-binary * "*")
(define-js-binary = "==")
(define-js-binary < "<")
(define-js-binary > ">")
(define-js-binary >> ">>")
(define-js-binary << "<<")
(define-js-binary mod "%")
(define-js-binary logxor "^")
(define-js-binary eq "===")
(define-js-binary eql "==")
(define-js-binary bit-and "&")
(define-js-binary bit-or "|")

(define-js-macro instance? (name typestring)
  `(%transpiler-native ,name instanceof ,typestring))

(define-js-macro make-array (&rest elements)
  `(%transpiler-native "[" ,@(transpiler-binary-expand "," elements) "]"))

(define-js-macro aref (arr &rest idx)
  `(%transpiler-native ,arr
    ,@(mapcar (fn `("[" ,_ "]"))
              idx)))

(define-js-macro href (arr &rest idx)
  `(%transpiler-native ,arr
    ,@(mapcar (fn `("[" ,_ "]"))
              idx)))

(define-js-macro %%usetf-aref (val &rest x)
  `(%transpiler-native (aref ,@x) "=" ,val))

(define-js-macro %%usetf-href (val &rest x)
  `(%transpiler-native (aref ,@x) "=" ,val))

(define-js-macro make-string (&optional size)
  `(%transpiler-string ""))

(define-js-macro make-hash-table (&rest args)
  `("{"
    ,@(when args
	    (mapcan (fn (list (first _) ":" (second _) ","))
			    (butlast (group args 2))))
    ,@(when args
		(with (x (car (last (group args 2))))
		  (list x. ":" (second x))))
   "}"))

(define-js-macro %new (&rest x)
  `(%transpiler-native "new "
				       ,x.
					   "(" ,@(transpiler-binary-expand "," .x)
 					   ")"))

(define-js-macro vm-go (tag)
  `("_=" ,(transpiler-symbol-string *js-transpiler* tag) "; continue"))

(define-js-macro vm-go-nil (val tag)
  `("if (!" ,val ") {_=" ,(transpiler-symbol-string *js-transpiler* tag) "; continue;}"))

(define-js-macro identity (x)
  x)

(defun js-stack (x)
  ($ '__S x))

(define-js-macro %stack (x)
  (js-stack x))

(define-js-macro %quote (x)
  `("symbol(\"" ,(symbol-name x) "\")"))

(define-js-macro %set-atom-fun (plc val)
  `(%transpiler-native ,plc "=" ,val))

(define-js-macro %slot-value (x y)
  ($ x "." y))
