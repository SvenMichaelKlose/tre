;;;;; TRE transpiler environment
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun %wrap-char-number (x)
  (? (character? x)
	 (char-code x)
	 x))

(defun + (&rest x)
  (let n (%wrap-char-number x.)
	(dolist (i .x n)
      (setf n (? (string? i)
	             (%%%string+ (string n) (string i))
	             (%%%+ n (%wrap-char-number i)))))))

(defun number+ (&rest x)
  (let n (%wrap-char-number x.)
	(dolist (i .x n)
	  (setf n (%%%+ n (%wrap-char-number i))))))

(defun integer+ (&rest x)
  (let n x.
    (dolist (i .x n)
      (setf n (%%%+ n i)))))

(defun character+ (&rest x)
  (let n 0
	(dolist (i .x (code-char n))
	  (setf n (%%%+ n (%wrap-char-number i))))))

(mapcan-macro gen
	'(-)
  (with (num ($ 'number gen)
		 int ($ 'integer gen)
		 chr ($ 'character gen)
		 op  ($ '%%% gen)
         gen-body `(let n (%wrap-char-number x.)
	    			 (dolist (i .x n)
	      			   (setf n (,op n (%wrap-char-number i))))))
    `((defun ,gen (&rest x)
	    ,gen-body)
	  (defun ,num (&rest x)
	    ,gen-body)
      (defun ,int (&rest x)
        (let n x.
	      (dolist (i .x n)
	        (setf n (,op n i)))))
      (defun ,chr (&rest x)
        (let n 0
	   	  (dolist (i .x (code-char n))
		    (setf n (,op n (%wrap-char-number i)))))))))

(mapcan-macro _
	'(= < > <= >=)
  (let op ($ '%%% _)
    `((defun ,_ (x y)
        (with (xn (%wrap-char-number x)
		       yn (%wrap-char-number y))
	      (,op xn yn)))
	  (defun ,($ 'integer _) (x y)
	    (,op x y))
	  (defun ,($ 'character _) (x y)
	    (,op x.v y.v)))))

(defun number? (x)
  (or (%number? x)
	  (character? x)))

(defun integer (x)
  (declare type number x)
  (?
    (character? x)
      (char-code x)
    (string? x)
      (string-integer x)
    x))
