;;;;; tré – Copyright (c) 2005–2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun %map-args (lists)
  (block nil
    (let* ((i lists)	        ; List iterator.
           (nl (make-queue)))	; Argument list.
      (tagbody
        start
        (? (not i)
           (return (queue-list nl)))
        (? (atom i)
           (error "List expected instead of ~A." i))
        (? (not (car i))	    ; Break if any list has no more elements.
           (return nil))
        (enqueue nl (caar i))	; Add head of list to list of arguments
        (rplaca i (cdar i))	    ; Move pointer to next element in list.
        (setq i (cdr i))	    ; Go for next list.
        (go start)))))

(defun map (func &rest lists)
  (let args (%map-args lists)
    (when args
      (apply func args)
	  (apply #'map func lists)))
  nil)

(defun mapcar (func &rest lists)
  (let args (%map-args lists)
    (& args
       (cons (apply func args) (apply #'mapcar func lists)))))

(defun mapcan (func &rest lists)
  (apply #'nconc (apply #'mapcar func lists)))

(defmacro dolist ((iter lst &rest result) &body body)
  (let* ((starttag (gensym))
         (endtag (gensym))
	     (tmplst (gensym)))
    `(block nil
       (let* ((,tmplst ,lst)
	          (,iter nil))
         (tagbody
           ,starttag
           (? (not ,tmplst)
              (go ,endtag))
           (? (not (list? ,tmplst))
              (error "List expected instead of ~A." ,tmplst))
           (setq ,iter (car ,tmplst))
           ,@body
           (setq ,tmplst (cdr ,tmplst))
           (go ,starttag)
           ,endtag
           (return (progn ,@result)))))))

(defun filter (func lst)
  (let result (cons nil nil)
    (dolist (i lst (cdr result))
      (rplaca result
              (cdr (rplacd (| (car result) result)
                           (list (funcall func i))))))))
