; tré – Copyright (c) 2008–2014,2016 Sven Michael Klose <pixel@hugbox.org>

(declare-cps-exception + - * / mod
                       == < > <= >=
                       number?
                       number number+ number- number== number< number> number<=
                       integer integer+ integer- integer== integer< integer> integer<= integer>=
                       character== character< character> character<= character>=)

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

(defmacro define-generic-transpiler-minus ()
  (let gen-body `(? .x
                    (let n x.
	   		          (adolist (.x n)
	      		        (= n (%%%- n !))))
                    (%%%- x.))
    `{(defun - (&rest x)
	    ,gen-body)
	  (defun number- (&rest x)
	    ,gen-body)
      (defun integer- (&rest x)
        (? .x
           (let n x.
	         (adolist (.x n)
	           (= n (%%%- n !))))
           (%%%- x.)))}))

(define-generic-transpiler-minus)

; TODO: CHARACTER shouldn't be a NUMBER.
(defmacro def-generic-transpiler-comparison (name)
  (let op ($ '%%% name)
    `{(defun ,name (n &rest x)
        (assert (| (number? n)
                   ,(? (eq name '+)
                       '(string? n)))
                "NUMBER expected instead of ~A." n)
        (adolist (x t)
          (assert (| (number? !)
                     ,(? (eq name '+)
                         '(string? !)))
                  "NUMBER expected instead of ~A." !)
          (| (,op n !)
             (return nil))
          (= n !)))
	  (defun ,($ 'integer name) (n &rest x)
        (assert (integer? n) "NUMBER expected instead of ~A." n)
        (adolist (x t)
          (assert (integer? !) "NUMBER expected instead of ~A." !)
          (| (,op n !)
             (return nil))
          (= n !)))
	  (defun ,($ 'character name) (n &rest x)
        (assert (character? n) "NUMBER expected instead of ~A." n)
        (let n (char-code n)
          (adolist (x t)
            (assert (character? !) "NUMBER expected instead of ~A." !)
            (| (,op n (char-code !))
               (return nil))
            (= n !))))}))

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
