(const *curl-error-codes*
  '(nil
    "CURLE_UNSUPPORTED_PROTOCOL"
    "CURLE_FAILED_INIT"
    "CURLE_URL_MALFORMAT"
    "CURLE_URL_MALFORMAT_USER"
    "CURLE_COULDNT_RESOLVE_PROXY"
    "CURLE_COULDNT_RESOLVE_HOST"
    "CURLE_COULDNT_CONNECT"
    "CURLE_FTP_WEIRD_SERVER_REPLY"
    "CURLE_REMOTE_ACCESS_DENIED"
    nil
    "FTP_WEIRD_PASS_REPLY"
    nil
    "FTP_WEIRD_PASV_REPLY"
    "FTP_WEIRD_227_FORMAT"
    "FTP_CANT_GET_HOST"
    nil
    "FTP_COULDNT_SET_TYPE"
    "PARTIAL_FILE"
    "FTP_COULDNT_RETR_FILE"
    nil
    "QUOTE_ERROR"
    "HTTP_RETURNED_ERROR"
    "WRITE_ERROR"
    "UPLOAD_FAILED"
    "READ_ERROR"
    "OUT_OF_MEMORY"
    "OPERATION_TIMEDOUT"
    nil
    "FTP_PORT_FAILED"
    "FTP_COULDNT_USE_REST"
    "RANGE_ERROR"
    "HTTP_POST_ERROR"
    "SSL_CONNECT_ERROR"
    "BAD_DOWNLOAD_RESUME"
    "FILE_COULDNT_READ_FILE"
    "LDAP_CANNOT_BIND"
    "LDAP_SEARCH_FAILED"
    nil
    "FUNCTION_NOT_FOUND"
    "ABORTED_BY_CALLBACK"
    "BAD_FUNCTION_ARGUMENT"
    nil
    "INTERFACE_FAILED"
    nil
    "TOO_MANY_REDIRECTS"
    "UNKNOWN_TELNET_OPTION"
    "TELNET_OPTION_SYNTAX"
    nil
    "PEER_FAILED_VERIFICATION"
    "GOT_NOTHING"
    "SSL_ENGINE_NOTFOUND"
    "SSL_ENGINE_SETFAILED"
    "SEND_ERROR"
    "RECV_ERROR"
    nil
    "SSL_CERTPROBLEM"
    "SSL_CIPHER"
    "SSL_CACERT"
    "BAD_CONTENT_ENCODING"
    "LDAP_INVALID_URL"
    "FILESIZE_EXCEEDED"
    "USE_SSL_FAILED"
    "SEND_FAIL_REWIND"
    "SSL_ENGINE_INITFAILED"
    "LOGIN_DENIED"
    "TFTP_NOTFOUND"
    "TFTP_PERM"
    "REMOTE_DISK_FULL"
    "TFTP_ILLEGAL"
    "TFTP_UNKNOWNID"
    "REMOTE_FILE_EXISTS"
    "TFTP_NOSUCHUSER"
    "CONV_FAILED"
    "CONV_REQD"
    "SSL_CACERT_BADFILE"
    "REMOTE_FILE_NOT_FOUND"
    "SSH"
    "SSL_SHUTDOWN_FAILED"
    "AGAIN"
    "SSL_CRL_BADFILE"
    "SSL_ISSUER_ERROR"
    "FTP_PRET_FAILED"
    "RTSP_CSEQ_ERROR"
    "RTSP_SESSION_ERROR"
    "FTP_BAD_FILE_LIST"
    "CHUNK_FAILED"))

; DATA is an associative list of key/value pairs.
(fn http-request (url data &key (header nil) (onerror nil) (onresult nil) (urlencoded? nil))
  (let c (curl_init)
    (curl_setopt c (%%native "CURLOPT_URL") url)
    (awhen header
      (curl_setopt c (%%native "CURLOPT_HTTPHEADER")
                   (list-phparray (mapcar [+ _. ": " ._]
                                          (? urlencoded?
                                             (. (. "Content-Type" "application/x-www-form-urlencoded")
                                                header)
                                             header)))))
    (curl_setopt c (%%native "CURLOPT_POST") T)
    (curl_setopt c (%%native "CURLOPT_POSTFIELDS")
                 (? (list? data)
                    (apply #'string-concat (pad (mapcar [+ _. "=" ._] data) "&"))
                    data))
    (curl_setopt c (%%native "CURLOPT_RETURNTRANSFER") T)
    (aprog1 (curl_exec c)
      (let errno (number (curl_errno c))
        (curl_close c)
        (? (zero? errno)
           (& onresult (funcall onresult !))
           (funcall onerror (+ "cURL error code '" errno "'/CURLE"
                               (elt errno *curl-error-codes*))))))))
