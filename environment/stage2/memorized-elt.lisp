;;;; TRE environment
;;;; Copyright (C) 2008-2009 Sven Klose <pixel@copei.de>

(defvar *mem-elt-seq* nil)
(defvar *mem-elt-seq-tmp* nil)
(defvar *mem-elt-idx* nil)

(defun memorized-elt (seq i)
  (if (consp seq)
      (if (and (eq seq *mem-elt-seq*)
			   *mem-elt-seq-tmp*
		       (= i (1+! *mem-elt-idx*)))
	      (car (setf *mem-elt-seq-tmp* (cdr *mem-elt-seq-tmp*)))
	      (progn
		    (setf *mem-elt-seq* seq
				  *mem-elt-seq-tmp* (nthcdr i seq)
			      *mem-elt-idx* i)
		    (car *mem-elt-seq-tmp*)))
	  (elt seq i)))
