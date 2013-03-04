;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defvar *obj-id-counter* 0)
(defvar *obj-keys* (%%%make-hash-table))

(defun make-hash-table (&key (test #'eql) (size nil))
  (aprog1 (%%%make-hash-table)
    (= !.__tre-test test)))

(defun %%objkey (x)     (%%%string+ "~~O" x))
(defun %%make-objkey () (%%objkey (= *obj-id-counter* (%%%+ 1 *obj-id-counter*))))
(defun %%numkey (x)     (%%%string+ "~~N" x))

(defun hashkeys (hash)
  (carlist (%property-list hash)))

(defun %make-href-object-key (key)
  (unless (defined? key.__tre-object-id)
    (let id (%%make-objkey)
      (= key.__tre-object-id id)
      (%%%=-aref key *obj-keys* id)))
  key.__tre-object-id)

(defun %href-key (key)
  (? (object? key)
     (%make-href-object-key key)
     (aprog1 (%%numkey key)
       (%%%=-aref key *obj-keys* !))))

(defun =-href-obj (value hash key)
  (%%%=-aref value hash (%href-key key)))

(defun %href-==? (x)
  (in? x #'== #'string== #'number== #'integer==))

(defun =-href (value hash key)
  (!? hash.__tre-test
      (? (%href-==? !)
         (%%%=-aref value hash key)
         (=-href-obj value hash key))
      (%%%=-aref value hash key)))

(defun %href-user (hash key)
  (dolist (k (hashkeys hash))
    (& (funcall hash.__tre-test k key)
       (return (%%%aref hash (%href-key key))))))

(defun href (hash key)
  (!? hash.__tre-test
      (?
        (%href-==? !) (%%%aref hash key)
        (eq #'eq !)   (%%%aref hash (? (object? key)
                                       key.__tre-object-id
                                       (%%numkey key)))
        (%href-user hash key))
      (%%%aref hash key)))

(defun hash-table? (x)
  (& (object? x)
     (undefined? x.__class)))

(defun hash-merge (a b)
  (when (| a b)
    (| a (= a (make-hash-table :test b.__tre-test)))
    (%setq nil (%transpiler-native
                   "for (var k in " b ") "
                       "if (k != \"" '__tre-object-id "\" && k !=\"" '__tre_test "\") "
                           a "[k] = " b "[k];"))
    a))

(defun copy-hash-table (x)
  (hash-merge nil x))
