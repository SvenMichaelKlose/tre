;;;;; tré – Copyright (c) 2008,2012 Sven Michael Klose <pixel@copei.de>

(defstruct text-container
  (x 0)
  (y 0)
  (lines nil))

(defun text-container-line (txt &optional (n nil))
  (elt (text-container-lines txt)
	   (| n (text-container-y txt))))

(defun (= text-container-line) (val txt &optional (n nil))
  (with (lines	(text-container-lines txt)
		 y		(| n (text-container-y txt)))
    (= (text-container-lines txt)
	   (nconc (subseq lines 0 y)
		      (list val)
		      (subseq lines (1+ y)))))
  val)

(defun text-container-up (txt &optional (n 1))
  (with (y	(text-container-y txt))
	(desaturate! (text-container-y txt) y n)
	(? (desaturates? y n) y n)))

(defun text-container-left (txt &optional (n 1))
  (with (x	(text-container-x txt))
	(desaturate! (text-container-x txt) x n)
	(? (desaturates? x n) x n)))

(defun text-container-down (txt &optional (n 1))
  (with (y		(text-container-y txt)
		 h		(1- (length (text-container-lines txt))))
	(saturate! (text-container-y txt) y n h)
	(? (saturates? y n h) (- h y) n)))

(defun text-container-right (txt &optional (n 1))
  (with (x		(text-container-x txt)
    	 line	(text-container-line txt)
    	 w		(1- (length line)))
	(saturate! (text-container-x txt) x n w)
	(? (saturates? x n w) (- w x) n)))

(defmacro define-text-container-modifier (name insertion)
  `(defun ,name (txt ,@(? insertion '(c)))
    (with (x		(text-container-x txt)
    	   line	(text-container-line txt))
	  (= (text-container-line txt)
	     (string-concat (| (subseq line 0 x) "")
					       ,@(? insertion (list `(string c)))
				           (| (subseq line ,(? insertion 'x '(1+ x))) ""))))))

(define-text-container-modifier text-container-insert-char t)
(define-text-container-modifier text-container-delete-char nil)
