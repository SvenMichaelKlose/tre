(fn form-element? (x)
  (& (element? x)
     (x.is? "input, textarea, select, option, radiobox")))

(fn submit-button? (x)
  (& (element? x)
     (x.is? "[type=submit]")))
