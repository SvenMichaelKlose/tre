;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun %wrap-char-number (x)
  (? (character? x)
	 (char-code x)
	 x))

(defmacro def-simple-op (op)
  `(defun ,op (&rest x)
     (let n (%wrap-char-number x.)
	   (adolist (.x n)
         (= n (,($ '%%% op) n (%wrap-char-number !)))))))

(mapcar-macro x '(* / mod)
  `(def-simple-op ,x))

(defun number+ (&rest x)
  (let n (%wrap-char-number x.)
	(adolist (.x n)
	  (= n (%%%+ n (%wrap-char-number !))))))

(defun integer+ (n &rest x)
  (adolist (x n)
    (= n (%%%+ n !))))

(defun character+ (&rest x)
  (let n 0
	(adolist (x (code-char n))
	  (= n (%%%+ n (%wrap-char-number !))))))

(defmacro define-generic-transpiler-minus ()
  (let gen-body `(? .x
                    (let n (%wrap-char-number x.)
	   		          (adolist (.x n)
	      		        (= n (%%%- n (%wrap-char-number !)))))
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
            (%%%- x.)))
       (defun character- (&rest x)
         (code-char ,gen-body)))))

(define-generic-transpiler-minus)

(defmacro def-generic-transpiler-comparison (name)
  (let op ($ '%%% name)
    `(progn
       (defun ,name (n-wrapped &rest x)
         (let n (%wrap-char-number n-wrapped)
           (adolist (x t)
             (| (,op n (%wrap-char-number !))
                (return nil))
             (= n !))))
	   (defun ,($ 'integer name) (n &rest x)
         (adolist (x t)
           (| (,op n !)
              (return nil))
           (= n !)))
	   (defun ,($ 'character name) (n-wrapped &rest x)
         (let n (%wrap-char-number n-wrapped)
           (adolist (x t)
             (| (,op n (%wrap-char-number !))
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
    (character? x) (char-code x)
    (string? x)    (string-integer x)
    (number-integer x)))
