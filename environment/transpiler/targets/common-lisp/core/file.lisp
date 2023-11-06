(defbuiltin %princ (x stream)
  (!= (| stream CL:*STANDARD-OUTPUT*)
    (?
      (character? x)  (CL:WRITE-BYTE (CL:CHAR-CODE x) !)
      (string? x)     (dosequence (i x)
                        (%princ i !))
      (CL:PRINC x !))))

(defbuiltin %force-output (stream) (CL:FORCE-OUTPUT stream))

(defbuiltin %fopen (pathname mode)
  (CL:OPEN pathname
           :DIRECTION (? (CL:FIND #\w mode :TEST #'CL:EQUAL)
                         :OUTPUT
                         :INPUT)
           :IF-EXISTS :SUPERSEDE
           :ELEMENT-TYPE '(CL:UNSIGNED-BYTE 8)))

(defbuiltin %fclose (stream) (CL:CLOSE stream))

(defbuiltin %read-char (str)
  (!= (CL:READ-BYTE (| str CL:*STANDARD-INPUT*) nil 'eof)
    (unless (eq ! 'eof)
      (CL:CODE-CHAR !))))

(defbuiltin file-exists? (pathname)
  (& (CL:PROBE-FILE pathname)
     t))
