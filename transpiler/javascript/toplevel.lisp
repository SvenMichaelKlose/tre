;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

(defun js-transpile (files &key (obfuscate? nil))
  (transpiler-reset *js-transpiler*)
  (transpiler-switch-obfuscator *js-transpiler* obfuscate?)
  (let f (make-string-stream)
    (format f "/*~%")
    (format f " * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>~%")
    (format f " *~%")
    (format f " * Softwarearchitekturbuero Sven Klose~%")
    (format f " * Westermuehlstrasse 31~%")
    (format f " * D-80469 Muenchen~%")
    (format f " * Tel.: ++49 / 89 / 57 08 22 38~%")
    (format f " *~%")
    (format f " * caroshi ECMAScript obfuscator~%")
    (format f " */~%")
    (princ (transpiler-transpile *js-transpiler*
			 (append (transpiler-sighten *js-transpiler* *js-base*)
					 (transpiler-sighten-files *js-transpiler* files)))
		   f)
    (get-stream-string f)))

;; XXX defunct
(defun js-machine (outfile)
  (with-open-file f (open outfile :direction 'output)
    (format f "~A"
			(transpiler-concat-strings
			  (transpiler-wanted *js-transpiler* #'transpiler-expand-and-generate-code (reverse *UNIVERSE*))))))
