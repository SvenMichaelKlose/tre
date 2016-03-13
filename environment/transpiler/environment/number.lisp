; tré – Copyright (c) 2008–2014,2016 Sven Michael Klose <pixel@hugbox.org>

(declare-cps-exception %wrap-char-number + - * / mod number+ integer+ character+ number- integer- character- == < > <= >= number== number< number> number<= number >= integer== integer< integer> integer<= integer>= character== character< character> character<= character>= number? integer)

(defun %wrap-char-number (x)
  (? (character? x)
	 (char-code x)
	 x))

(defun number== (x &rest y)
  (every [%%%== x _] y))

(defmacro def-simple-op (op)
  `(defun ,op (&rest x)
     (let n x.
	   (adolist (.x n)
         (= n (,($ '%%% op) n !))))))

(mapcar-macro x '(* / mod)
  `(def-simple-op ,x))

(defun number+ (&rest x)
  (let n x.
	(adolist (.x n)
	  (= n (%%%+ n !)))))

(defun integer+ (n &rest x)
  (adolist (x n)
    (= n (%%%+ n !))))

(defun character+ (&rest x)
  (let n 0
	(adolist (x (code-char n))
	  (= n (%%%+ n (%wrap-char-number !))))))

(defmacro define-generic-transpiler-minus ()
  (let gen-body `(? .x
                    (let n x.
	   		          (adolist (.x n)
	      		        (= n (%%%- n !))))
                    (%%%- x.))
    `(progn
       (defun - (&rest x)
	     ,gen-body)
	   (defun number- (&rest x)
	     ,gen-body)
       (defun integer- (&rest x)
         (? .x
            (let n x.
	          (adolist (.x n)
	            (= n (%%%- n !))))
            (%%%- x.))))))

(define-generic-transpiler-minus)

(defun character- (&rest x)
  (code-char (? .x
                (let n (char-code x.)
	   		      (adolist (.x n)
	      	        (= n (%%%- n (char-code !)))))
                (%%%- (char-code x.)))))

(defmacro def-generic-transpiler-comparison (name)
  (let op ($ '%%% name)
    `(progn
       (defun ,name (n &rest x)
         (adolist (x t)
           (| (,op n !)
              (return nil))
           (= n !)))
	   (defun ,($ 'integer name) (n &rest x)
         (adolist (x t)
           (| (,op n !)
              (return nil))
           (= n !)))
	   (defun ,($ 'character name) (n-wrapped &rest x)
         (let n (char-code n-wrapped)
           (adolist (x t)
             (| (,op n (char-code !))
                (return nil))
             (= n !)))))))

(def-generic-transpiler-comparison ==)
(def-generic-transpiler-comparison <)
(def-generic-transpiler-comparison >)
(def-generic-transpiler-comparison <=)
(def-generic-transpiler-comparison >=)

(defun number? (x)
  (| (%number? x)
     (character? x)))

(defun integer (x)
  (?
    (character? x)  (char-code x)
    (string? x)     (string-integer x)
    (number-integer x)))
