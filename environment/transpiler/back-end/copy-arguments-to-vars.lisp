(defun copy-arguments-to-vars (fi)
  (& (copy-arguments-to-stack?)
     (mapcan [& (funinfo-var? fi _)
                `((%= ,(place-assign (place-expand-0 fi _)) ,_))]
             (funinfo-local-args fi))))
