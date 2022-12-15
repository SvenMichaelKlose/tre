(fn form-element? (x)
  (& (element? x)
     (x.is? "input, textarea, select, option, radiobox")))

(fn submit-button? (x)
  (& (element? x)
     (x.is? "[type=submit]")))

(fn form-text-element? (x)
  (& (not (submit-button? x))
     (x.is? "input, textarea")))
