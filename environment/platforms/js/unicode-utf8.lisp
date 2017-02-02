(fn unicode-utf8 (x)
  (unescape (encode-u-r-i-component x)))

(fn utf8-unicode (x)
  (decode-u-r-i-component (escape x)))
