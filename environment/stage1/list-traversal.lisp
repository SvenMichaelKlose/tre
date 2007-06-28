;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; List traversal

(defun %map (func lists)
  "Copy heads of lists into returned list.
   Destructively removes heads from lists."
  (block nil
    (let ((i lists)		; List iterator.
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
  (%map func lists))

(defun %mapcar (func lists)
  "Calls function for all head CARs in lists. Then call with next elements.
   If a list runs out of elements, the function stops."
  (let ((args (%map func lists)))
    (when args
      (cons (apply func args) (%mapcar func lists)))))

(defun mapcar (func &rest lists)
  (%mapcar func (copy-tree lists)))

(defun mapcan (func &rest lists)
  "Like MAPCAR but concatenate the resulting lists."
  (apply #'nconc (apply #'mapcar func lists)))

(defmacro dolist ((iter lst &rest result) &rest body)
  "Iterate over list."
  (let ((starttag (gensym))
        (endtag (gensym))
	(tmplst (gensym)))
    `(block nil
      (let ((,tmplst ,lst)
	    (,iter nil))
        (tagbody
          ,starttag
          (if (eq ,tmplst nil)
            (go ,endtag))
          (setq ,iter (car ,tmplst))
          ,@body
          (setq ,tmplst (cdr ,tmplst))
          (go ,starttag)
          ,endtag
          (return (progn ,@result)))))))

(defmacro dolist-skipatoms ((iter lst &rest result) &rest body)
  (let ((starttag (gensym))
        (endtag (gensym))
	(tmplst (gensym)))
    `(block nil
      (let ((,tmplst ,lst)
	    (,iter nil))
        (tagbody
          ,starttag
          (if (not (consp ,tmplst))
            (go ,endtag))
          (setq ,iter (car ,tmplst))
          ,@body
          (setq ,tmplst (cdr ,tmplst))
          (go ,starttag)
          ,endtag
          (return (progn ,@result)))))))

(defmacro dolist-indexed ((iter index lst result &key (start-index 0))
			  &rest body)
  "Iterate over list."
  (let ((starttag (gensym))
        (endtag (gensym))
	(tmplst (gensym)))
    `(block nil
      (let ((,tmplst ,lst)
	    (,iter nil)
	    (,index ,start-index))
        (tagbody
          ,starttag
          (if (eq ,tmplst nil)
            (go ,endtag))
          (setq ,iter (car ,tmplst))
          ,@body
          (setq ,tmplst (cdr ,tmplst))
	  (setq ,index (+ 1 ,index))
          (go ,starttag)
          ,endtag
          (return ,result))))))
