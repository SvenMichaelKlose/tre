;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@hugbox.org>

(defun directory-tree (pathname)
  (let d (%directory pathname)
    (when (number? d)
      (? (== 13 d)
         (return nil))
      (error (%strerror d)))
    (filter [? (| (string== "." _)
                  (string== ".." _))
               _
               (with (p  (string-concat pathname "/" _)
                      s  (stat p))
                 (& (number? s)
                    (error (%strerror s)))
                 (alet (+ (list (. 'name _))
                          s)
                   (? (& (eq 'directory (assoc-value 'type ! :test #'eq))
                         (not (readlink p)))
                      (. (. 'list (directory-tree p)) !)
                      !)))]
            d)))
