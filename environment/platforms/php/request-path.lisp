;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defvar *request-path-offset* nil)
(defvar *base-url* nil)

(defun parse-request-path ()
  (with (path  (%%%href *_SERVER* "SCRIPT_NAME")
         comp  (path-pathlist path)
         ofs   (? comp
                  (-- (length comp))
                  0))
    (= *request-path-offset* ofs)
    (= *base-url* (pathlist-path (subseq comp 0 ofs)))))

(parse-request-path)

(dont-obfuscate parse_url)

(defun request-uri () 
  (href *_SERVER* "REQUEST_URI"))

(defun parse-url ()
  (parse_url (request-uri)))

(defun request-path ()
  (href (parse-url) "path"))

(defun request-path-components ()
  (subseq (path-pathlist (request-uri)) *request-path-offset*))
