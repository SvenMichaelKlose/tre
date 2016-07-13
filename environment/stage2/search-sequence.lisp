; tré – Copyright (c) 2005–2006,2008-2009,2011–2016 Sven Michael Klose <pixel@hugbox.org>

(functional find position)

(defun %find-if-list (pred seq from-end with-index)
  (alet (? from-end
           (reverse seq)
           seq)
    (? with-index
       (let idx 0
         (adolist !
           (& (funcall pred ! idx)
              (return !))
           (++! idx)))
       (adolist !
         (& (funcall pred !)
            (return !))))))

(defun %find-if-sequence (pred seq start end from-end with-index)
  (& seq (< 0 (length seq))
     (let* ((e (| end (-- (length seq))))
	 	    (s (| start 0)))
       ; Make sure the start and end indexes are sane.
       (& (| (& (> s e) (not from-end))
             (& (< s e) from-end))
          (xchg s e))
       (do ((i s (? from-end
				    (-- i)
				    (++ i))))
           ((? from-end
	           (< i e)
			   (> i e)))
	     (alet (elt seq i)
           (& (apply pred (. ! (& with-index (list i))))
		      (return !)))))))
 
(defun find-if (pred seq &key (start nil) (end nil) (from-end nil) (with-index nil))
  (? (not (atom seq) start end)
     (%find-if-list pred seq from-end with-index)
     (%find-if-sequence pred seq start end from-end with-index)))

(defun find-if-not (pred seq &key (start nil) (end nil) (from-end nil) (with-index nil))
  (find-if [not (funcall pred _)] seq :start start :end end :from-end from-end :with-index with-index))

(defun find (obj seq &key (start nil) (end nil) (from-end nil) (test #'eql))
  (find-if [funcall test _ obj] seq :start start :end end :from-end from-end))

(defun position (obj seq &key (start nil) (end nil) (from-end nil) (test #'eql))
  (aprog1 nil
    (find-if #'((x i)
                 (& (funcall test x obj)
                    (= ! i)))
             seq :start start :end end :from-end from-end :with-index t)))

(defun position-if (pred seq &key (start nil) (end nil) (from-end nil))
  (aprog1 nil
    (find-if #'((x i)
				  (& (funcall pred x)
					 (= ! i)))
			 seq :start start :end end :from-end from-end :with-index t)))

(defun some (pred &rest seqs)
  (find-if pred (apply #'append seqs)))

(defun every (pred &rest seqs)
  (@ (seq seqs t)
    (adotimes ((length seq))
      (| (funcall pred (elt seq !))
         (return-from every nil)))))

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

(define-test "POSITION works with character list"
  ((position 's '(l i s p)))
  2)

(define-test "POSITION works with strings"
  ((position #\/ "lisp/foo/bar"))
  4)

(define-test "SOME works"
  ((& (some #'number? '(a b 3)))
      (not (some #'number? '(a b c))))
  t)

(define-test "EVERY works"
  ((& (every #'number? '(1 2 3))
      (not (every #'number? '(1 2 a)))))
  t)
