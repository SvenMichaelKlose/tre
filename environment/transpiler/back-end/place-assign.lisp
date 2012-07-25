;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defun unassigned-%stack? (x)
  (& (%stack? x) ..x))

(defun unassigned-%vec? (x)
  (& (%vec? x) ...x))

(defun unassigned-%set-vec? (x)
  (& (%set-vec? x) ....x))

(defun place-assign-error (x v)
  (error "can't assign place because the find index in lexicals for ~A in ~A.~%" v x))

(define-tree-filter place-assign (x)
  (| (%quote? x)
     (%transpiler-native? x)) x
  (unassigned-%stack? x)       `(%stack ,(+ (funinfosym-env-pos .x. ..x.)
                                               (? (transpiler-arguments-on-stack? *current-transpiler*)
                                                  (length (funinfo-args (get-funinfo-by-sym .x.)))
                                                  0)))
  (unassigned-%vec? x)         `(%vec ,(place-assign .x.)
		                              ,(| (funinfosym-lexical-pos ..x. ...x.)
                                          (place-assign-error x ...x.)))
  (unassigned-%set-vec? x)     `(%set-vec ,(place-assign .x.)
		                                  ,(| (funinfosym-lexical-pos ..x. ...x.)
                                              (place-assign-error x ...x.))
                                          ,(place-assign ....x.))
  (lambda? x)                  (copy-lambda x :body (place-assign (lambda-body x)))
  (%slot-value? x)             `(%slot-value ,(place-assign .x.) ,..x.))
