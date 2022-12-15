(fn multipart-rand ()
  (string (+ 1000 (*math.floor (*math.random 8999)))))

(var *multipart-boundary* (base64-encode (apply #'+ (maptimes #'(() (multipart-rand)) 4))))

(fn multipart-formdata (key value)
  (+ "--" *multipart-boundary* *terpri*
     "Content-disposition: form-data; name=\"" key "\"" *terpri*
     *terpri*
     value *terpri*))

(fn multipart-tail ()
  (+ "--" *multipart-boundary* "--" *terpri*))

; DATA is an associative list of key/value pairs.
(fn http-request (url data &key (onerror nil) (onresult nil))
  (with (req       (new *x-m-l-http-request)
         listener  [0 & (== 4 req.ready-state)
                        (? (== 200 req.status)
                           (funcall onresult req.response-text)
                           (funcall onerror req url data))])
    (& onresult
       (= req.onreadystatechange listener))
    (req.open "POST" url (& onresult t))
    (req.set-request-header "Content-type" (+ "multipart/form-data; charset=UTF-8; boundary="
                                              *multipart-boundary*))
    (req.send (+ (apply #'string-concat (@ [multipart-formdata _. ._] data))
                 (multipart-tail)))
    (unless onresult
      (| (== 200 req.status)
         (funcall onerror req url data))
      req.response-text)))

(fn ajax (url data &key (onerror nil) (onresult nil) (post? t))
  (with (req       (new *x-m-l-http-request)
         listener  [0 & (== 4 req.ready-state)
                        (? (== 200 req.status)
                           (funcall onresult req.response)
                           (funcall onerror req url data))])
    (& onresult
       (= req.onreadystatechange listener))
    (req.open (? post? "POST" "GET") url (& onresult t))
    (req.set-request-header "Content-type" (+ "application/json; charset=UTF-8; boundary="
                                              *multipart-boundary*))
    (req.send (json-encode data))
    (unless onresult
      (| (== 200 req.status)
         (funcall onerror req url data))
      req.response)))

(fn http-request-error (req url data)
  (error (+ "Connection error: " req.status
            ", URL: " url
            " response: " req.response-text
            " params: " data)))
