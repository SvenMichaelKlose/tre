;;;;; tré – Copyright (c) 2005–2006,2008-2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(functional find position)

(defmacro xchg (a b)
  (with-gensym g
    `(let ,g ,a
	   (= ,a ,b
	   	  ,b ,g))))

(defun %find-if-list (pred seq from-end with-index)
  (alet (? from-end
           (reverse seq)
           seq)
    (? with-index
       (let idx 0
         (dolist (i !)
           (& (funcall pred i idx)
              (return i))
           (++! idx)))
       (dolist (i !)
         (& (funcall pred i)
            (return i))))))

(defun %find-if-sequence (pred seq start end from-end with-index)
  (& seq (integer< 0 (length seq))
     (let* ((e (| end (integer-- (length seq))))
	 	    (s (| start 0)))
       ; Make sure the start and end indices are sane.
       (& (| (& (integer> s e) (not from-end))
             (& (integer< s e) from-end))
          (xchg s e))
       (do ((i s (? from-end
				    (integer-- i)
				    (integer++ i))))
           ((? from-end
	           (integer< i e)
			   (integer> i e)))
	     (let elm (elt seq i)
           (& (apply pred (cons elm (& with-index (list i))))
		      (return elm)))))))
 
(defun find-if (pred seq &key (start nil) (end nil) (from-end nil) (with-index nil))
  (? (not (atom seq) start end)
     (%find-if-list pred seq from-end with-index)
     (%find-if-sequence pred seq start end from-end with-index)))

(defun find (obj seq &key (start nil) (end nil) (from-end nil) (test #'eql))
  (find-if [funcall test _ obj] seq :start start :end end :from-end from-end))

(define-test "FIND finds elements"
  ((find 's '(l i s p)))
  's)

(define-test "FIND accepts :FROM-END"
  ((find 's '(l i s p) :from-end t))
  's)

(define-test "FIND accepts :END"
  ((find 's '(l i s p) :end 1))
  nil)

(define-test "FIND accepts :START"
  ((find 'l '(l i s p) :start 1))
  nil)

(define-test "FIND accepts :START, :END, :FROM-END"
  ((find 'l '(l i s p) :start 1 :end 2 :from-end 1))
  nil)

(define-test "FIND-IF finds elements"
  ((find-if #'number? '(l i 5 p)))
  5)

(defun position (obj seq &key (start nil) (end nil) (from-end nil) (test #'eql))
  (let *position-index* nil
    (find-if #'((x i)
                 (& (funcall test x obj)
                    (= *position-index* i)))
             seq :start start :end end :from-end from-end :with-index t)
	  *position-index*))

(define-test "POSITION works with character list"
  ((position 's '(l i s p)))
  2)

(define-test "POSITION works with strings"
  ((position #\/ "lisp/foo/bar"))
  4)

(defun position-if (pred seq &key (start nil) (end nil) (from-end nil))
  (let *position-index* nil
    (find-if #'((x i)
				  (& (funcall pred x)
					 (= *position-index* i)))
			 seq :start start :end end :from-end from-end :with-index t)
	  *position-index*))

(defun some (pred &rest seqs)
  (find-if pred (apply #'append seqs)))

(define-test "SOME works"
  ((& (some #'number? '(a b 3)))
      (not (some #'number? '(a b c))))
  t)

(defun every (pred &rest seqs)
  (dolist (seq seqs t)
    (dotimes (i (length seq))
      (| (funcall pred (elt seq i))
         (return-from every nil)))))

(define-test "EVERY works"
  ((& (every #'number? '(1 2 3))
      (not (every #'number? '(1 2 a)))))
  t)
