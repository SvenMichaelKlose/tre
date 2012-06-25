;;;;; tré – Copyright (c) 2005-2006,2008-2009,2012 Sven Michael Klose <pixel@copei.de>

(functional eql equal
            == < > <= >=
            number+ number- number== number< number> number<= number>=
            integer+ integer- integer== integer< integer> integer<= integer>=
            character== character> character< character<= character>=)

(defun equal (x y)
  (?
	(or (atom x)
		(atom y))
      (eql x y)
    (equal (car x)
		   (car y))
      (equal (cdr x)
			 (cdr y))))

(define-test "EQUAL with CONS"
  ((equal (list 'x)
		  (list 'x)))
  t)

(define-test "EQUAL fails on different lists"
  ((equal '(1 2) '(3 4)))
  nil)
