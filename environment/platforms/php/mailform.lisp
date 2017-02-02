(defvar __rfc2110boundary (uniqid (rand)))
(defvar *rfc2110comment* nil)

(fn rfc2110-boundary ()
  (+ "rfc2110_boundary_cs" __rfc2110boundary))

(fn rfc2110-header (fromemail)
  (+ "From: " fromemail "\n"
	 "Reply-To: " fromemail "\n"
	 "X-Mailer: tre rfc2110 support.\n"
    	 "Mime-Version: 1.0\n"
	 "Content-Type: Multipart/mixed; boundary=\""
	 (rfc2110-boundary ) "\""))

(fn rfc2110-tail ()
  (+ "--" (rfc2110-boundary) "--\n"))

(fn rfc2110-attachment (content type &optional (encoding 0) (contentid 0) inlinepath)
  (let header ""
    (unless *rfc2110comment*
      (= *rfc2110comment* t)
      (= header "  This is a multipart mime message.\n\n"))
    (= header (+ header "--" (rfc2110-boundary) "\n"))
    (when contentid
      (= header (+ header "Content-ID: " contentid "\n")))
    (when type
      (= header (+ header "Content-Type: " type "\n")))
    (when encoding
      (= header (+ header "Content-Transfer-Encoding: " encoding "\n")))
    (when inlinepath
      (= inlinepath (+ inlinepath "Content-Disposition: inline; filename=\"" inlinepath "\"\n")))
    (+ header "\n" content)))

(fn rfc2110-file (filename type)
  (with (fd (fopen filename "r")
         bin (fread fd (filesize filename))
         image (base64_encode bin))
    (fclose fd)
    (dotimes (i (length image))
      (= attachment (+ attachment (substr image i 64) "\n"))
      (= i (+ i 64)))
    (rfc2110-attachment
        attachment
        (+ type "; name=\"" filename "\"\n"
		  "Content-Disposition: inline; filename=\"" filename "\"\n"
		  "Content-MD5: " (md5 bin))
        "base64")))

(fn send-mail (subject to body customer)
  (mail to subject
    	(rfc2110-attachment body "text/plain; charset=UTF-8")
      	(rfc2110-header (urldecode customer))))

(fn send-html-mail (from subject to body)
  (mail to subject
        (rfc2110-attachment body "text/html; charset=UTF-8")
      	(rfc2110-header from)))
