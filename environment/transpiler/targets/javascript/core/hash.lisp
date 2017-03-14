(var *obj-id-counter* 0)

(fn make-hash-table (&key (test #'eql) (size nil))
  (aprog1 (%%%make-object)
    (= !.__tre-test test)
    (unless (%href-==? test)
      (= !.__tre-keys (%%%make-object)))))

(fn hash-table? (x)
  (& (object? x)
     (undefined? x.__class)))

(fn %htest (x)
  (& (defined? x.__tre-test)
     x.__tre-test))

(fn %%objkey ()
  (setq *obj-id-counter* (%%%+ 1 *obj-id-counter*))
  (%%%string+ "~~O" *obj-id-counter*))

(fn %%numkey (x)
  (%%%string+ "~~N" x))

(fn hashkeys (hash)
  (? (& (hash-table? hash)
        (defined? hash.__tre-keys))
     (cdrlist (%property-list hash.__tre-keys))
     (carlist (%property-list hash))))

(fn %make-href-object-key (hash key)
  (unless (defined? key.__tre-object-id)
    (= key.__tre-object-id (%%objkey)))
  (%%%=-aref key hash.__tre-keys key.__tre-object-id)
  key.__tre-object-id)

(fn %href-key (hash key)
  (? (object? key)
     (%make-href-object-key hash key)
     (aprog1 (%%numkey key)
       (%%%=-aref key hash.__tre-keys !))))

(fn =-href-obj (value hash key)
  (%%%=-aref value hash (%href-key hash key)))

(fn %href-==? (x)
  (| (eq x #'==)
     (eq x #'string==)
     (eq x #'number==)))

(fn =-href (value hash key)
  (!? (%htest hash)
      (? (%href-==? !)
         (%%%=-aref value hash key)
         (=-href-obj value hash key))
      (%%%=-aref value hash key)))

(fn %href-user (hash key)
  (@ (k (hashkeys hash))
    (& (funcall hash.__tre-test k key)
       (return (%%%aref hash (%href-key hash k))))))

(fn href (hash key)
  (!? (%htest hash)
      (?
        (eq #'eq !)   (%%%aref hash (? (object? key)
                                       key.__tre-object-id
                                       (%%numkey key)))
        (%href-==? !) (%%%aref hash key)
        (%href-user hash key))
      (%%%aref hash key)))

(fn hash-merge (a b)
  (when (| a b)
    (| a (= a (make-hash-table :test b.__tre-test)))
    (? (defined? b.__tre-keys)
       (= a.__tre-keys (*object.create b.__tre-keys)))
    (%= nil (%%native
                "for (var k in " b ") "
                    "if (k != \"" '__tre-object-id "\" && k != \"" '__tre-test "\" && k != \"" '__tre-keys "\") "
                        a "[k] = " b "[k];"))
    a))

(fn copy-hash-table (x)
  (hash-merge nil x))
