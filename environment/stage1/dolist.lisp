; tré – Copyright (c) 2005–2009,2012–2013,2016 Sven Michael Klose <pixel@copei.de>

(defmacro dolist ((iter lst &rest result) &body body)
  (let* ((starttag  (gensym))
         (endtag    (gensym))
	     (tmplst    (gensym)))
    `(block nil
       (let* ((,tmplst  ,lst)
	          (,iter    nil))
         (tagbody
           ,starttag
           (? (not ,tmplst)
              (go ,endtag))
           (setq ,iter (car ,tmplst))
           ,@body
           (setq ,tmplst (cdr ,tmplst))
           (go ,starttag)
           ,endtag
           (return {,@result}))))))
