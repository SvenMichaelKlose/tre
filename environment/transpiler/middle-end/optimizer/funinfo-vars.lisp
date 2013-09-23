;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun opt-places-find-used-1 (x fi)
  (& (symbol? x)
     (funinfo-var? fi x)
     (funinfo-add-used-var fi x)))

(metacode-walker opt-places-find-used-0 (x fi)
  :if-named-function (let fi (get-lambda-funinfo x.)
                       (!? (funinfo-lexical fi)
                           (funinfo-add-used-var fi !))
                       (funinfo-add-used-var fi (lambda-name x.))
                       (opt-places-find-used-0 (lambda-body x.) fi))
  :if-go-nil (opt-places-find-used-1 .x. fi)
  :if-setq (with (x x.
                  p (%setq-place x)
                  v (%setq-value x))
             (opt-places-find-used-1 p fi)
             (?
               (symbol? v) (opt-places-find-used-1 v fi)
               (& (cons? v)
                  (dolist (i v)
                    (opt-places-find-used-1 i fi))))))

(defun opt-places-find-used (x)
  (opt-places-find-used-0 x (transpiler-global-funinfo *transpiler*))
  x)

(defun move-~%ret-to-front (x)
  (? (member '~%ret x :test #'eq)
     (cons '~%ret (remove '~%ret x :test #'eq))
     x))

(defun opt-places-used-vars (fi)
  (+ (funinfo-lexicals fi)
     (intersect (funinfo-vars fi) (funinfo-used-vars fi) :test #'eq)
     (& (transpiler-copy-arguments-to-stack? *transpiler*)
        (funinfo-args fi))))

(defun opt-places-correct-funinfo (fi)
  (funinfo-vars-set fi (move-~%ret-to-front (opt-places-used-vars fi))))

(defun opt-places-remove-unused-body (x)
  (let fi (get-lambda-funinfo x)
    (opt-places-correct-funinfo fi)
    (opt-places-remove-unused-0 fi (lambda-body x))))

(defun opt-places-remove-unused-0 (fi x)
  (?
    (atom x)          nil
    (named-lambda? x) (opt-places-remove-unused-body x)
    (progn
      (opt-places-remove-unused-0 fi x.)
      (opt-places-remove-unused-0 fi .x))))

(defun opt-places-remove-unused (x)
  (opt-places-remove-unused-0 (transpiler-global-funinfo *transpiler*) x)
  x)

(defun optimize-funinfo-vars (x)
  (opt-places-remove-unused (opt-places-find-used x)))
