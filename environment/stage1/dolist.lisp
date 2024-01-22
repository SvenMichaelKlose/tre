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
           (return (progn
                     ,@result)))))))
