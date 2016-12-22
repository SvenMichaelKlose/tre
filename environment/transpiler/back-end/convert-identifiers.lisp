; tré – Copyright (c) 2008–2009,2011–2016 Sven Michael Klose <pixel@copei.de>

(defun transpiler-translate-symbol (tr from to)
  (acons! from to (transpiler-symbol-translations tr)))

(defun transpiler-special-char? (x)
  (not (funcall (identifier-char?) x)))

(defun global-variable-notation? (x)
  (let l (length x)
    (& (< 2 l)
       (eql (elt x 0) #\*)
       (eql (elt x (-- l)) #\*))))

(defun convert-identifier-r (s)
  (with (camel-notation
		   #'((x pos)
               (with (bump?
                       [& ._
                          (| (& (eql #\- _.)
                                (alpha-char? ._.))
                             (& (eql #\* _.)
                                (zero? pos)))])
                 (& x
                    (? (bump? x)
                       (. (char-upcase .x.)
                          (camel-notation ..x (++ pos)))
                       (. (char-downcase x.)
                          (camel-notation .x (++ pos)))))))
		 corrected-chars
           #'((x pos)
               (with (char-synonym  [? (& ._ (eql #\- _.))
                                       (list #\_)
                                       (string-list (+ "T" (format nil "~A" (char-code _.))))])
                 (& x
                    (? (| (& (zero? pos)
                             (digit-char? x.))
                          (transpiler-special-char? x.))
                       (+ (char-synonym x) (corrected-chars .x (++ pos)))
                       (. x. (corrected-chars .x (++ pos)))))))
         capitals
           [remove #\- (string-list (upcase (subseq _ 1 (-- (length _))))) :test #'character==])
	(? (| (string? s)
          (number? s)
          (character? s))
	   (string s)
       (list-string (alet (symbol-name s)
	                  (corrected-chars (? (global-variable-notation? !)
                                          (capitals !)
    	                                  (camel-notation (string-list !) 0))
                                       0)))))) ; TODO: Argument keywords for local functions.

(defun convert-identifier (s)
  (| (href (identifiers) s)
     (let n (!? (defined-package (symbol-package s))
                (convert-identifier-r (make-symbol (+ (symbol-name (symbol-package s)) ":" (symbol-name s))))
                (convert-identifier-r s))
       (awhen (href (converted-identifiers) n)
         (error "Identifier clash: symbol ~A and ~A are both converted to ~A."
                s ! n))
       (= (href (identifiers) s) n)
       (= (href (converted-identifiers) n) s)
       n)))

(defun convert-identifiers (x)
  (maptree [?
             (string? _)         _
             (| (number? _)
                (character? _))  (princ _ nil)
             (symbol? _)         (| (assoc-value _ (symbol-translations) :test #'eq)
                                    (convert-identifier _))
             (%%string? _)       (funcall (gen-string) ._.)
             (%%native? _)       (convert-identifiers ._)
             (cons? _)           _
             (error "Cannot translate ~A to string." _)]
           x))
