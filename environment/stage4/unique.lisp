;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun unique-0 (head tail)
  (when head
	(if (= head tail.)
	  (unique-0 head .tail)
	  (cons head
			(unique-0 tail. .tail)))))

(defun unique (x &key (test #'<=))
  (let sorted (sort x :test test)
    (unique-0 sorted. .sorted)))
