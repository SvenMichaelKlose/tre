;;;;; tré – Copyright (c) 2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate is_a)

(defun %%key (x)
  (?
    (is_a x "__symbol")    (%%%string+ "~%S" x.n "~%P" x.p)
    (is_a x "__cons")      (%%%string+ "~%L" x.id)
    (is_a x "__array")     (%%%string+ "~%A" x.id)
    (is_a x "__character") (%%%string+ "~%C" x.v)
    x))

(defun %%unkey-get-package-boundary (x)
  (awhen (position #\~ x :test #'character==)
    (& (== #\% (elt x (+ 1 !)))
       (== #\P (elt x (+ 2 !)))
       (| (%%unkey-get-package-boundary (string-subseq ! 3))
          !))))

(defun %%unkey (x)
  (? (& (== #\~ (elt x 0))
        (== #\% (elt x 1)))
     (alet (string-subseq x 3)
       (case (elt x 2) :test #'character==
         #\S (let boundary (%%unkey-get-package-boundary !)
               (make-symbol (subseq ! 0 boundary)
                            (let-when p (subseq ! (+ 3 boundary))
                              (make-symbol p))))
         #\L (%%%href *conses* (string-subseq x 3))
         #\A (%%%href *arrays* (string-subseq x 3))
         #\C (code-char (string-subseq x 3))
         (error "illegal index ~A" x)))
     x))

(defun hash-table? (x)
  (is_a x "__array"))

(defun hashkeys (x)
  (? (hash-table? x)
     (filter #'%%unkey (x.keys))
     (maparray #'identity (phphash-hashkeys x))))

(defun hash-merge (a b)
  (| a (= a (make-hash-table)))
  (dolist (k (hashkeys b) a)
    (= (href a k) (href b k))))

(defun alist-phphash (x)
  (let a (%%%make-hash-table)
    (dolist (i x a)
      (%%%href-set .i a i.))))

(defun href (h k)
  (alet (%%key k)
    (?  (| (is_a h "__l") 
           (is_a h "__array"))
        (h.g !)
        (& (php-aref-defined? h !)
           (php-aref h !)))))

(defun (= href) (v h k)
  (alet (%%key k)
    (?  (| (is_a h "__l") 
           (is_a h "__array"))
        (h.s (%%key !) v)
        (=-php-aref v h !) v))
  v)
