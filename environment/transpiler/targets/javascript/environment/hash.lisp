;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defvar *obj-id-counter* 0)
(defvar *obj-keys* (%%%make-hash-table))

(defun make-hash-table (&key (test #'eql) (size nil))
  (aprog1 (%%%make-hash-table)
    (= !.__tre-test test)))

(defmacro %%key (key)
  `(%%%string+ "~~id" ,key))

(defun hashkeys (hash)
  (carlist (%property-list hash)))

(defun %%u=-href (value hash key)
  (?
    (character? key)
      (= (aref hash (%%%string+ "~%C" key.v)) value)
    (object? key)
      (progn
        (unless (defined? key.__tre-object-id)
          (let id (%%key (= *obj-id-counter* (%%%+ 1 *obj-id-counter*)))
            (= key.__tre-object-id id
               (aref *obj-keys* id) key)))
        (= (aref hash key.__tre-object-id) value))
    (= (aref hash key) value)))

(defun href (hash key)
  (? 
    (character? key)
      (aref hash (%%%string+ "~%C" key.v))
    (object? key)
      (? (defined? key.__tre-object-id)
         (aref hash key.__tre-object-id))
    (and (defined? hash.__tre-test)
         (not (%%%eq #'eq hash.__tre-test)
              (and (string? key)
                   (%%%eq #'string== hash.__tre-test))))
      (dolist (k (hashkeys hash))
        (when (funcall hash.__tre-test (aref hash key))
          (return (aref hash key))))
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

(defun hash-merge (a b)
  (when (or a b)
    (unless a
      (= a (make-hash-table)))
    (%setq nil (%transpiler-native
                   "for (var k in " b ") "
                       "if (k != \"" '__tre-object-id "\" && k !=\"" '__tre_test "\") "
                           a "[k] = " b "[k];"))
    a))

(defun copy-hash-table (x)
  (hash-merge nil x))
