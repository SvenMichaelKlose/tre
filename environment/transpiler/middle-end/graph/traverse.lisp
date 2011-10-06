;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defmacro cblock-traverse-next (fun cb visited-blocks)
  (with-gensym visited-and-this
    `(let ,visited-and-this (cons ,cb ,visited-blocks)
       (awhen (cblock-next ,cb)
         (,fun ! ,visited-and-this))
       (awhen (cblock-conditional-next ,cb)
         (,fun ! ,visited-and-this)))))
