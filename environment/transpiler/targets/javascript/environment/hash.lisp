;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defvar *obj-id-counter* 0)
(defvar *obj-keys* (%%%make-hash-table))

(defmacro %%key (key)
  `(%%%string+ "~~id" ,key))

(defun %%usetf-href (value hash key)
  (? (object? key)
     (progn
       (unless (defined? key._caroshi-object-id)
         (let id (%%key (setf *obj-id-counter* (%%%+ 1 *obj-id-counter*)))
           (setf key._caroshi-object-id id
                 (aref *obj-keys* id) key)))
       (setf (aref hash key._caroshi-object-id) value))
     (setf (aref hash key) value)))

(defun href (hash key)
  (? (object? key)
     (? (defined? key._caroshi-object-id)
        (aref hash key._caroshi-object-id))
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

(defun hashkeys (hash)
  (carlist (%property-list hash)))

(defun hash-merge (a b)
  (when (or a b)
    (unless a
      (setf a (make-hash-table)))
    (%setq nil (%transpiler-native
                   "for (var k in " b ") "
                       "if (k != \"" '_caroshi-object-id "\") "
                           a "[k] = " b "[k];"))
    a))

(defun copy-hash-table (x)
  (hash-merge nil x))
