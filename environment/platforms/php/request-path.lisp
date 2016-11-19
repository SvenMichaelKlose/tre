; tré – Copyright (c) 2012–2014,2016 Sven Michael Klose <pixel@copei.de>

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

(defun request-uri () 
  (aref *_SERVER* "REQUEST_URI"))

(dont-obfuscate parse_url)

(defun parse-url ()
  (parse_url (request-uri)))

(defun request-path ()
  (aref (parse-url) "path"))

(defun request-path-components ()
  (remove-if #'empty-string? (subseq (path-pathlist (request-uri)) *request-path-offset*)))
