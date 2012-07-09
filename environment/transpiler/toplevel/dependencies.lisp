;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun get-require-paths (toplevel-expressions)
  (mapcan (fn & (cons? _) (eq 'require _.)
                (? (string? ._.)
                   (list ._.)
                   (error "REQUIRE expects a literal string.")))
          toplevel-expressions))

(defun get-dependencies (x)
  (unique (apply #'+ (filter (fn (format t "; Getting requirements for \"~A\"...~F" _)
                                 (prog1
                                   (get-require-paths (read-file-all _))
                                   (format t " Done.~%")))
                             x))
          :test #'==))
