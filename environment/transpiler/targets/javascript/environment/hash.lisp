;;;;; tré - Copyright (c) 2009-2011 Sven Klose <pixel@copei.de>

(defun %href-object-key (key)
  (string-concat "_caroshi_obj" key._caroshi-object-id))

(defun %href-make-object-key (key)
  (unless (defined? key._caroshi-object-id)
    (setf key._caroshi-object-id (gensym-number))))

(defun %%usetf-href (value hash key)
  (? (object? key)
     (progn
       (%href-make-object-key key)
       (let obj-key (%href-object-key key)
         (setf obj-key._caroshi-key-object key)
         (setf (aref hash obj-key) value)))
     (setf (aref hash key) value)))

(defun href (hash key)
  (? (object? key)
     (? (defined? key._caroshi-object-id)
        (aref hash (%href-object-key key)))
     (aref hash key)))

(defun hash-table? (x)
  (and (object? x)
       (undefined? x.__class)))

(defun hash-assoc (x)
  (with-queue q
    (maphash #'((k v)
				 (enqueue q (cons (? (defined? k._caroshi-key-object)
                                       k._caroshi-key-object
                                       k)
                                  v)))
         	 x)
    (queue-list q)))

(defun hashkeys (x)
  (with-queue q
    (maphash #'((k v)
				 (enqueue q k))
             x)
    (queue-list q)))

(defun hash-merge (a b)
  (declare type (hash-table nil) a b)
  (when (or a b)
    (unless a
      (setf a (make-hash-table)))
    (%setq nil (%transpiler-native "for (var " k " in " b ") " a "[" k "]=" b "[" k "];"))
    a))
