(defmacro php-define-compiled-literal (name (x table) &key maker init-maker)
  `(define-compiled-literal ,name (,x ,table)
	   :maker      ,maker
	   :init-maker ,init-maker
	   :decl-maker [identity nil]))

(php-define-compiled-literal php-compiled-char (x char)
  :maker (add-late-symbol($ 'char_ (char-code x)))
  :init-maker `(%%native "new __character (" ,(char-code x) ")"))

(php-define-compiled-literal php-compiled-symbol (x symbol)
  :maker ($ 'symbol_ (? (keyword? x) '_ "") x)
  :init-maker `(%%native "new __symbol ("
			  	             (%%string ,(symbol-name x))
                             ","
			   	             ,(? (keyword? x)
                                 "$KEYWORDPACKAGE"
                                 "NULL")
				         ")"))
