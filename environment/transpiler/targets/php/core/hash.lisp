(defun hash-table? (x)
  (is_a x "__array"))

(defun %%key (x)
  (?
    (is_a x "__symbol")    (%%%string+ "~%S" x.n "~%P" (? (keyword? x)
                                                          "_kw"
                                                          x.p))
    (is_a x "__cons")      (%%%string+ "~%L" x.id)
    (is_a x "__array")     (%%%string+ "~%A" x.id)
    (is_a x "__character") (%%%string+ "~%C" x.v)
    x))

(defun %%unkey (x)
  (? (%%%== "~%" (substr x 0 2))
     (alet (substr x 3)
       (case (substr x 2 1) :test #'%%%==
         "S" (let boundary (strpos ! "~%P")
               (make-symbol (subseq ! 0 boundary)
                            (let-when p (subseq ! (+ 3 boundary))
                              (? (%%%== p "_kw")
                                 *keyword-package*
                                 (make-symbol p)))))
         "L" (%%%href *conses* (substr x 3))
         "A" (%%%href *arrays* (substr x 3))
         "C" (code-char (substr x 3))
         (error "Illegal index ~A." x)))
     x))

(defun hashkeys (x)
  (? (hash-table? x)
     (@ #'%%unkey (x.keys))
     (maparray #'identity (phphash-hashkeys x))))

(defun hash-merge (a b)
  (| a (= a (make-hash-table)))
  (@ (k (hashkeys b) a)
    (= (href a k) (href b k))))

(defun alist-phphash (x)
  (let a (%%%make-hash-table)
    (@ (i x a)
      (%%%href-set .i a i.))))

(defun phphash-alist (x)
  (with-queue q
    (@ (i (hashkeys x) (queue-list q))
      (enqueue q (. i (aref x i))))))

(defun %href-error (h)
  (error "HREF expects an hash table instead of ~A." h))

(defun href (h k)
  (alet (%%key k)
    (? (is_a h "__array")
       (h.g !)
       (& (php-aref-defined? h !)
          (php-aref h !)))))

(defun (= href) (v h k)
  (alet (%%key k)
    (?  (is_a h "__array")
        (h.s (%%key !) v)
        (=-php-aref v h !) v))
  v)
