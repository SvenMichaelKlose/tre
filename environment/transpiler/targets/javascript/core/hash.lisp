(defvar *obj-id-counter* 0)

(defun make-hash-table (&key (test #'eql) (size nil))
  (aprog1 (%%%make-hash-table)
    (= !.__tre-test test)
    (unless (%href-==? test)
      (= !.__tre-keys (%%%make-hash-table)))))

(defun hash-table? (x)
  (& (object? x)
     (undefined? x.__class)))

(defun %htest (x)
  (& (defined? x.__tre-test)
     x.__tre-test))

(defun %%objkey ()
  (setq *obj-id-counter* (%%%+ 1 *obj-id-counter*))
  (%%%string+ "~~O" *obj-id-counter*))

(defun %%numkey (x)
  (%%%string+ "~~N" x))

(defun hashkeys (hash)
  (? (& (hash-table? hash)
        (defined? hash.__tre-keys))
     (cdrlist (%property-list hash.__tre-keys))
     (carlist (%property-list hash))))

(defun %make-href-object-key (hash key)
  (unless (defined? key.__tre-object-id)
    (alet (%%objkey)
      (= key.__tre-object-id !)
      (%%%=-aref key hash.__tre-keys !)))
  key.__tre-object-id)

(defun %href-key (hash key)
  (? (object? key)
     (%make-href-object-key hash key)
     (aprog1 (%%numkey key)
       (%%%=-aref key hash.__tre-keys !))))

(defun =-href-obj (value hash key)
  (%%%=-aref value hash (%href-key hash key)))

(defun %href-==? (x)
  (in? x #'== #'string== #'number== #'integer==))

(defun =-href (value hash key)
  (!? (%htest hash)
      (? (%href-==? !)
         (%%%=-aref value hash key)
         (=-href-obj value hash key))
      (%%%=-aref value hash key)))

(defun %href-user (hash key)
  (adolist ((hashkeys hash))
    (& (funcall hash.__tre-test ! key)
       (return (%%%aref hash (%href-key hash !))))))

(defun href (hash key)
  (!? (%htest hash)
      (?
        (eq #'eq !)   (%%%aref hash (? (object? key)
                                       key.__tre-object-id
                                       (%%numkey key)))
        (%href-==? !) (%%%aref hash key)
        (%href-user hash key))
      (%%%aref hash key)))

(defun hash-merge (a b)
  (when (| a b)
    (| a (= a (make-hash-table :test b.__tre-test)))
    (? (defined? b.__tre-keys)
       (= a.__tre-keys (*Object.create b.__tre-keys)))
    (%= nil (%%native
                "for (var k in " b ") "
                    "if (k != \"" '__tre-object-id "\" && k != \"" '__tre-test "\" && k != \"" '__tre-keys "\") "
                        a "[k] = " b "[k];"))
    a))

(defun copy-hash-table (x)
  (hash-merge nil x))
