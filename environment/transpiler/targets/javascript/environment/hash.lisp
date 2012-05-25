;;;;; tré - Copyright (c) 2009-2012 Sven Michael Klose <pixel@copei.de>

(defvar *obj-id-counter* 0)

(defun %href-object-key (key)
  (%%%string+ "~~id" key._caroshi-object-id))

(defun %href-make-object-key (key)
  (unless (defined? key._caroshi-object-id)
    (setf key._caroshi-object-id (1+! *obj-id-counter*))))

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
                 (unless (%%%= "~~id" (k.substr 0 4))
				   (enqueue q k)))
             x)
    (queue-list q)))

(defun hash-merge (a b)
  (when (or a b)
    (unless a
      (setf a (make-hash-table)))
    (%setq nil (%transpiler-native "for (var " k " in " b ") if (" k ".substr (0,4) != \"~~id\") " a "[" k "]=" b "[" k "];"))
    a))

(defun copy-hash-table (x)
  (hash-merge nil x))
