(fn %write-vim-keywords (o x)
  (@ [format o "syn keyword lispFunc ~A~%" (downcase _)]
     (remove-if [head? "%"_] (@ #'symbol-name (carlist x)))))

(format t "Making VIM syntax file…~%")
(with-output-file o "tre.vim"
  (%write-vim-keywords o *functions*)
  (%write-vim-keywords o *macros*))
