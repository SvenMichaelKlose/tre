;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun %wrap-char-number (x)
  (? (character? x)
	 (char-code x)
	 x))

(defun + (&rest x)
  (? (listp x.)
     (apply #'append x)
     (let n (%wrap-char-number x.)
	   (dolist (i .x n)
         (= n (? (| (string? n) (string? i))
	             (%%%string+ (string n) (string i))
	             (%%%+ n (%wrap-char-number i))))))))

(defun * (&rest x)
  (let n (%wrap-char-number x.)
	(dolist (i .x n)
      (= n (%%%* n (%wrap-char-number i))))))

(defun / (&rest x)
  (let n (%wrap-char-number x.)
	(dolist (i .x n)
      (= n (%%%/ n (%wrap-char-number i))))))

(defun mod (&rest x)
  (let n (%wrap-char-number x.)
	(dolist (i .x n)
      (= n (%%%mod n (%wrap-char-number i))))))

(defun number+ (&rest x)
  (let n (%wrap-char-number x.)
	(dolist (i .x n)
	  (= n (%%%+ n (%wrap-char-number i))))))

(defun integer+ (n &rest x)
  (dolist (i x n)
    (= n (%%%+ n i))))

(defun character+ (&rest x)
  (let n 0
	(dolist (i x (code-char n))
	  (= n (%%%+ n (%wrap-char-number i))))))

(defmacro define-generic-transpiler-minus ()
  (let gen-body `(? .x
                    (let n (%wrap-char-number x.)
	   		          (dolist (i .x n)
	      		        (= n (%%%- n (%wrap-char-number i)))))
                    (%%%- x.))
    `(progn
       (defun - (&rest x)
	     ,gen-body)
	   (defun number- (&rest x)
	     ,gen-body)
       (defun integer- (&rest x)
         (? .x
            (let n x.
	          (dolist (i .x n)
	            (= n (%%%- n i))))
            (%%%- x.)))
       (defun character- (&rest x)
         (code-char ,gen-body)))))

(define-generic-transpiler-minus)

(defmacro def-generic-transpiler-comparison (name)
  (let op ($ '%%% name)
    `(progn
       (defun ,name (n-wrapped &rest x)
         (let n (%wrap-char-number n-wrapped)
           (dolist (i x t)
             (unless (,op n (%wrap-char-number i))
               (return nil))
             (= n i))))
	   (defun ,($ 'integer name) (n &rest x)
         (dolist (i x t)
           (unless (,op n i)
             (return nil))
           (= n i)))
	   (defun ,($ 'character name) (n-wrapped &rest x)
         (let n (%wrap-char-number n-wrapped)
           (dolist (i x t)
             (unless (,op n (%wrap-char-number i))
               (return nil))
             (= n i)))))))

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
    (string? x) (string-integer x)
    (number-integer x)))
