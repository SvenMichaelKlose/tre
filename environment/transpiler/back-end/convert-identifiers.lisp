; tré – Copyright (c) 2008–2009,2011–2015 Sven Michael Klose <pixel@copei.de>

(defun transpiler-translate-symbol (tr from to)
  (acons! from to (transpiler-symbol-translations tr)))

(defun transpiler-special-char? (x)
  (not (funcall (identifier-char?) x)))

(defun global-variable-notation? (x)
  (let l (length x)
    (& (< 2 l)
       (== (elt x 0) #\*)
       (== (elt x (-- l)) #\*))))

(defun convert-identifier-r (s)
  (with (encapsulate-char
		   [string-list (string-concat "T" (format nil "~A" (char-code _)))]
				
		 convert-camel
		   #'((x pos)
                (& x
			       (let c (char-downcase x.)
			         (? (& .x (| (character== #\- c)
                                 (& (== 0 pos)
                                    (character== #\* c))))
                        (? (& (character== #\- c)
                              (not (alphanumeric? .x.)))
                           (+ (string-list "T45")
                              (convert-camel .x (++ pos)))
					       (. (char-upcase (cadr x))
						      (convert-camel ..x (++ pos))))
					    (. c (convert-camel .x (++ pos)))))))

         convert-special2
           [& _
              (? (transpiler-special-char? _.)
                 (+ (encapsulate-char _.)
                    (convert-special2 ._))
                 (. _. (convert-special2 ._)))]

		 convert-special
           [& _
              (? (digit-char? _.)
                 (+ (encapsulate-char _.)
                    (convert-special2 ._))
                 (convert-special2 _))]
         convert-global
           [remove-if [== _ #\-]
                      (string-list (upcase (subseq _ 1 (-- (length _)))))])
	(? (| (string? s) (number? s))
	   (string s)
       (list-string
           (let str (symbol-name s)
	         (convert-special (? (global-variable-notation? str)
                                 (convert-global str)
    	                         (convert-camel (string-list str) 0))))))))


(defun convert-identifier (s)
  (| (href (identifiers) s)
     (let n (!? nil ;(symbol-package s)
                (convert-identifier-r (make-symbol (+ (symbol-name !) ":" (symbol-name s))))
                (convert-identifier-r s))
       (awhen (href (converted-identifiers) n)
         (error "Identifier clash: symbol ~A and ~A are both converted to ~A."
                s ! n))
       (= (href (identifiers) s) n)
       (= (href (converted-identifiers) n) s)
       n)))

(defun convert-identifiers (x)
  (maptree [?
             (string? _)    _
             (number? _)    (princ _ nil)
             (symbol? _)    (| (assoc-value _ (symbol-translations) :test #'eq)
                               (convert-identifier _))
             (%%string? _)  (funcall (gen-string) ._.)
             (%%native? _)  (convert-identifiers ._)
             (cons? _)      _
             (error "Cannot translate ~A to string." _)]
           x))
