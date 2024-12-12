(defbuiltin %princ (x stream)
  (!= (| stream CL:*STANDARD-OUTPUT*)
    (?
      (character? x)  (CL:WRITE-BYTE (CL:CHAR-CODE x) !)
      (string? x)     (dosequence (i x)
                        (%princ i !))
      (CL:PRINC x !))))

(defbuiltin %force-output (stream)
  (CL:FORCE-OUTPUT stream))

(defbuiltin %fopen (file-specifier mode)
  (CL:OPEN file-specifier
           :DIRECTION (? (CL:FIND #\w mode :TEST #'CL:EQUAL)
                         :OUTPUT
                         :INPUT)
           :IF-EXISTS :SUPERSEDE
           :ELEMENT-TYPE '(CL:UNSIGNED-BYTE 8)))

(defbuiltin %fclose (stream)
  (CL:CLOSE stream))

(defbuiltin %read-char (str)
  (!= (CL:READ-BYTE (| str CL:*STANDARD-INPUT*) nil 'eof)
    (unless (eq ! 'eof)
      (CL:CODE-CHAR !))))

(defbuiltin file-exists? (file-specifier)
  (& (CL:PROBE-FILE file-specifier)
     t))

(defbuiltin directory (file-specifier)
  (CL:DIRECTORY (+ file-specifier "*.*"))) ; SBCL version
