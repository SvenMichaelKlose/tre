(defun number== (x &rest y)
  (every [%%%== x _] y))

(defmacro def-simple-op (op)
  `(defun ,op (&rest x)
     (let n x.
	   (@ (i .x n)
         (= n (,($ '%%% op) n i))))))

(mapcar-macro x '(* / mod)  ; TODO: Map to %%%…?
  `(def-simple-op ,x))

(defun number+ (&rest x)
  (let n x.
	(@ (i .x n)
	  (= n (%%%+ n i)))))

(defmacro define-generic-transpiler-minus ()
  (let gen-body `(? .x
                    (let n x.
	   		          (adolist (.x n)
	      		        (= n (%%%- n !))))
                    (%%%- x.))
    `{(defun - (&rest x)
	    ,gen-body)
	  (defun number- (&rest x)
	    ,gen-body)}))

(define-generic-transpiler-minus)

(defmacro def-generic-transpiler-comparison (name)
  (let op ($ '%%% name)
    `{(defun ,name (n &rest x)
        (@ (i x t)
          (| (,op n i)
             (return))
          (= n i)))
	  (defun ,($ 'character name) (n &rest x)
        (let n (char-code n)
          (@ (i x t)
            (| (,op n (char-code i))
               (return))
            (= n i))))}))

(def-generic-transpiler-comparison ==)
(def-generic-transpiler-comparison <)
(def-generic-transpiler-comparison >)
(def-generic-transpiler-comparison <=)
(def-generic-transpiler-comparison >=)

(defun number? (x)
  (%number? x))

(defun integer (x)
  (?
    (character? x)  (char-code x)
    (string? x)     (string-integer x)
    (number-integer x)))

(defun << (a b)      (%%%<< a b))
(defun >> (a b)      (%%%>> a b))
(defun bit-or (a b)  (%%%bit-or a b))
(defun bit-and (a b) (%%%bit-and a b))
