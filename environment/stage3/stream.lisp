;;;; tré – Copyright (c) 2005-2006,2010,2012 Sven Michael Klose <pixel@copei.de>

(defstruct stream
  (handle nil)

  fun-in
  fun-out
  fun-eof

  (last-char	nil)
  (peeked-char	nil)

  (track-input-location?  t)
  (in-line      1)
  (in-column    1)
  (in-tabsize   8)

  (track-output-location? nil)
  (out-line     1)
  (out-column   1)

  (user-detail nil))

(defun %stream-track-input-location (str x)
  (when (stream-track-input-location? str)
    (? (string? x)
       (dolist (i (string-list x))
         (%stream-track-input-location str i))
       (? (== 10 x)
          (progn
            (= (stream-in-column str) 1)
            (1+! (stream-in-line str)))
          (?
            (== 9 x) (= (stream-in-column str) (* (stream-in-tabsize str) (1+ (integer (/ (stream-in-column str) (stream-in-tabsize str))))))
            (< 31 x) (1+! (stream-in-column str))))))
  x)
