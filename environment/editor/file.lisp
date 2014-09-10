;;;;; tré – Copyright (c) 2008,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun editor-read-line (str &optional (n 1))
  (when (peek-char str)
    (editor-io-line n)
    (cons (read-line str) (editor-read-line str (++ n)))))

(defun editor-write (name text)
  (with-open-file str (open name :direction 'output)
    (let n 1
      (mapcar [(editor-io-line n)
               (++! n)
               (format str "~A~%" (| _ ""))]
              (text-container-lines text)))))

(defun editor-read (name)
  (with-open-file str (open name :direction 'input)
    (editor-read-line str)))
