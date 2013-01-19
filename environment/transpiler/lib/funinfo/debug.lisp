;;;;; tré – Copyright (C) 2006–2007,2009,2012–2013 Sven Michael Klose <pixel@copei.de>

;;;; DEBUG PRINTERS

(defun print-funinfo (fi)
  (with-funinfo fi
    (format t "Arguments:      ~A~%" args)
    (format t "Ghost argument: ~A~%" ghost)
    (format t "Local vars:     ~A~%" vars)
    (format t "Lexicals:       ~A~%" lexicals)
    (format t "Lexical array:  ~A~%" lexical)
    (format t "Free vars:      ~A~%" free-vars)
    (format t "Used vars:      ~A~%" used-vars)
    (format t "-~%"))
  fi)

(defun print-funinfo-stack (fi &key (include-global? nil))
  (when fi
    (print-funinfo fi)
    (print-funinfo-stack (funinfo-parent fi) :include-global? include-global?))
  fi)
