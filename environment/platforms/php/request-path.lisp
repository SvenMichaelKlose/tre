(var *request-path-offset* nil)
(var *base-url* nil)

(fn parse-request-path ()
  (with (path  (%aref *_SERVER* "SCRIPT_NAME")
         comp  (path-pathlist path)
         ofs   (? comp
                  (-- (length comp))
                  0))
    (= *request-path-offset* ofs)
    (= *base-url* (pathlist-path (subseq comp 0 ofs)))))

(parse-request-path)

(fn request-uri () 
  (aref *_SERVER* "REQUEST_URI"))

(fn parse-url ()
  (parse_url (request-uri)))

(fn request-path ()
  (aref (parse-url) "path"))

(fn request-path-components ()
  (remove-if #'empty-string? (subseq (path-pathlist (request-uri)) *request-path-offset*)))
