;;;; TRE environment
;;;; Copyright (C) 2005-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; List traversal

(defun %map (func lists)
  "Copy heads of lists into returned list.
   Destructively removes heads from lists."
  (block nil
    (let* ((i lists)	; List iterator.
           (nl (make-queue)))	; Argument list.
      (tagbody
        start
        (if (endp i)	; Stop at end of lists.
          (return (queue-list nl)))
        (if (not (car i))	; Break if any list has no more elements.
          (return nil))
        (enqueue nl (caar i))	; Add head of list to list of arguments
        (rplaca i (cdar i))	; Move pointer to next element in list.
        (setq i (cdr i))	; Go for next list.
        (go start)))))

(defun map (func &rest lists)
  "Calls function for all head CARs in lists. Then call with next elements.
   If a list runs out of elements, the function stops.
   Returns NIL."
  (let args (%map func lists)
    (when args
      (apply func args)
	  (apply #'map func lists)))
  nil)

(defun mapcar (func &rest lists)
  "Calls function for all head CARs in lists. Then call with next elements.
   If a list runs out of elements, the function stops.
Returns a list of all return values of the function."
  (let args (%map func lists)
    (when args
      (cons (apply func args) (apply #'mapcar func lists)))))

(defun mapcan (func &rest lists)
  "Like MAPCAR but concatenate the resulting lists."
  (apply #'nconc (apply #'mapcar func lists)))

(defmacro dolist ((iter lst &rest result) &rest body)
  "Iterate over list."
  (let* ((starttag (gensym))
         (endtag (gensym))
	     (tmplst (gensym)))
    `(block nil
      (let* ((,tmplst ,lst)
	         (,iter nil))
        (tagbody
          ,starttag
          (if (not ,tmplst)
            (go ,endtag))
          (setq ,iter (car ,tmplst))
          ,@body
          (setq ,tmplst (cdr ,tmplst))
          (go ,starttag)
          ,endtag
          (return (progn ,@result)))))))

(defun filter (func lst)
  "Calls function for all elements in list and returns a
list of all return values."
  (when lst
	(cons (funcall func (car lst))
		  (filter func (cdr lst)))))

(defun filter-concat (func lst)
  "Calls function for all elements in list and returns a concatenated
list of all return values."
  (funcall #'nconc func lst))
