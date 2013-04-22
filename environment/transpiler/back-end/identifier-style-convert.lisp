;;;;; tré – Copyright (c) 2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun transpiler-translate-symbol (tr from to)
  (acons! from to (transpiler-symbol-translations tr)))

(defun transpiler-special-char? (tr x)
  (not (funcall (transpiler-identifier-char? tr) x)))

(defun global-variable-notation? (x)
  (let l (length x)
    (& (< 2 l)
       (== (elt x 0) #\*)
       (== (elt x (1- l)) #\*))))

(defun transpiler-symbol-string-r (tr s)
  (with (encapsulate-char
		   [string-list (string-concat "T" (format nil "~A" (char-code _)))]
				
		 convert-camel
		   #'((x pos)
                (& x
			       (let c (char-downcase x.)
			         (? (& .x (| (character== #\- c)
                                 (& (== 0 pos)
                                    (character== #\* c))))
					    (cons (char-upcase (cadr x))
						      (convert-camel ..x (1+ pos)))
					    (cons c (convert-camel .x (1+ pos)))))))

         convert-special2
           [& _
              (let c _.
                (? (transpiler-special-char? tr c)
                   (append (encapsulate-char c)
                           (convert-special2 ._))
                   (cons c (convert-special2 ._))))]

		 convert-special
           [& _
              (let c _.
                   ; Encapsulate initial char if it's a digit.
                   (? (digit-char-p c)
                      (append (encapsulate-char c)
                              (convert-special2 ._))
                      (convert-special2 _)))]
         convert-global
           [remove-if [== _ #\-]
                      (string-list (string-upcase (subseq _ 1 (1- (length _)))))])
	(? (| (string? s) (number? s))
	   (string s)
       (list-string
           (let str (symbol-name s)
	         (convert-special (? (global-variable-notation? str)
                                 (convert-global str)
    	                         (convert-camel (string-list str) 0))))))))

(defun transpiler-symbol-string-0 (tr s)
  (!? (symbol-package s)
      (transpiler-symbol-string-r tr (make-symbol (string-concat (symbol-name !) ":" (symbol-name s))))
      (transpiler-symbol-string-r tr s)))

(defun transpiler-dot-symbol-string (tr sl)
  (apply #'string-concat (pad (filter [transpiler-symbol-string-0 tr (make-symbol (list-string _))]
		                              (split #\. sl))
                              ".")))

(defun transpiler-symbol-string (tr s)
  (let sl (string-list (symbol-name s))
    (? (position #\. sl)
	   (transpiler-dot-symbol-string tr sl)
	   (transpiler-symbol-string-0 tr s))))

(defun current-transpiler-symbol-string (s)
  (transpiler-symbol-string *transpiler* s))

(defun transpiler-to-string-cons (tr x)
  (?
    (%transpiler-string? x) (funcall (transpiler-gen-string tr) .x.)
    (%transpiler-native? x) (transpiler-to-string tr .x)
    x))

(defun transpiler-to-string (tr x)
  (maptree [?
             (cons? _)    (transpiler-to-string-cons tr _)
             (string? _)  _
             (symbol? _)  (| (assoc-value _ (transpiler-symbol-translations tr) :test #'eq)
                             (transpiler-symbol-string tr _))
             (number? _)  (princ _ nil)
             (error "Cannot translate ~A to string" _)]
           x))
