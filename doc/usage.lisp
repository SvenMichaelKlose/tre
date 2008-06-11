(section
	(title "Usage")
    (para
		"tre [-h] [-i image-file] [source-file]")

	(para
      	"-h  Print help message."
		"-i  Load image file before source-file. See SYS-IMAGE-CREATE for details.")

	(para
		"First, the interpreter checks if an image of the standard environment"
		"exists. It is usually placed at ~/.tre.image. It is then loaded"
		"instead of the source files."
		"Otherwise, the source files of the environment are read and an image"
		"file is written to speed up the next program start."))
