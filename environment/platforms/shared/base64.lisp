(defvar *base64-key*
  		"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=")

(defun base64-encode-char (x)
  (string (elt *base64-key* x)))

(defun base64-encode (x)
  (let out ""
	(let len (length x)
	  (while x
		     out
	    (with (c1 x.
			   c2 (when .x .x.)
			   c3 (when ..x ..x.)
	  		   e1 (>> c1 2)
			   e2 (bit-or (<< (bit-and c1 3)
							  4)
						  (>> (| c2 0) 4))
			   e3 (? c2
				     (bit-or (<< (bit-and c2 15)
							     2)
						     (>> (| c3 0) 6))
					 64)
			   e4 (? c3
					 (bit-and c3 63)
					 64))
          (= x ...x)
		  (+! out (base64-encode-char e1)
				  (base64-encode-char e2)
				  (base64-encode-char e3)
				  (base64-encode-char e4)))))))
 
(defun base64-decode-char (x)
  (position x *base64-key* :test #'==))

(defun base64-compress (x)
  (when x
    (? (| (alphanumeric? x.)
          (in? x. #\+ #\/ #\=))
       (. x. (base64-compress .x))
       (base64-compress .x))))

(defun base64-decode (x)
  (let out ""
	(= x (base64-compress x))
	(let len (length x)
	  (while x out
	    (with (e1 (base64-decode-char x.)
	  		   e2 (base64-decode-char .x.)
	  		   e3 (base64-decode-char ..x.)
	  		   e4 (base64-decode-char ...x.)
			   c1 (bit-or (<< e1 2)
						  (>> e2 4))
			   c2 (bit-or (<< (bit-and e2 15)
							  4)
						  (>> e3 2))
			   c3 (bit-or (<< (bit-and e3 3)
							  6)
						  e4))
			  (= x ....x)
			  (+! out (string (code-char c1))
					  (? (not (== 64 e3))
					     (string (code-char c2))
					     "")
				      (? (not (== 64 e4))
					     (string (code-char c3))
					     "")))))))
