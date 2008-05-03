;;;;; TRE environment - editor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; File I/O.

(defun editor-read-line (str &optional (n 1))
  (when (not (end-of-file str))
    (editor-io-line n)
    (cons (read-line str) (editor-read-line str (1+ n)))))

(defun editor-write (name)
  (with-open-file str (open name :direction 'output)
    (with (n 1)
	  (mapcar #'((x)
				   (editor-io-line n)
				   (incf n)
				   (format str "~A~%" (or x "")))
		     (text-container-lines *text*)))))

(defun editor-read (name)
  (with-open-file str (open name :direction 'input)
    (editor-read-line str)))
