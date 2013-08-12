;;;;; tré – Copyright (c) 2008,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun editor-read-line (str &optional (n 1))
  (when (not (end-of-file str))
    (editor-io-line n)
    (cons (read-line str) (editor-read-line str (++ n)))))

(defun editor-write (name text)
  (with-open-file str (open name :direction 'output)
    (with (n 1)
	  (mapcar #'((x)
				   (editor-io-line n)
				   (++! n)
				   (format str "~A~%" (| x "")))
		     (text-container-lines text)))))

(defun editor-read (name)
  (with-open-file str (open name :direction 'input)
    (editor-read-line str)))
