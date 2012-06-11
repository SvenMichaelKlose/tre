;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defvar *obj-id-counter* 0)
(defvar *obj-keys* (%%%make-hash-table))

(defun make-hash-table (&key (test #'eql) (size nil))
  (aprog1 (%%%make-hash-table)
    (setf !.__tre-test test)))

(defmacro %%key (key)
  `(%%%string+ "~~id" ,key))

(defun %%usetf-href (value hash key)
  (?
    (character? key)
      (setf (aref hash (%%%string+ "~%C" key.v)) value)
    (object? key)
      (progn
        (unless (defined? key._caroshi-object-id)
          (let id (%%key (setf *obj-id-counter* (%%%+ 1 *obj-id-counter*)))
            (setf key._caroshi-object-id id
                  (aref *obj-keys* id) key)))
        (setf (aref hash key._caroshi-object-id) value))
    (setf (aref hash key) value)))

(defun href (hash key)
  (? 
    (character? key)
      (aref hash (%%%string+ "~%C" key.v))
    (object? key)
      (? (defined? key._caroshi-object-id)
         (aref hash key._caroshi-object-id))
    (aref hash key)))

(defun hash-table? (x)
  (and (object? x)
       (undefined? x.__class)))

(defun hash-assoc (x)
  (with-queue q
    (maphash #'((k v)
				 (enqueue q (cons k v)))
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
                       "if (k != \"" '_caroshi-object-id "\" && k !=\"" '__tre_test "\") "
                           a "[k] = " b "[k];"))
    a))

(defun copy-hash-table (x)
  (hash-merge nil x))
