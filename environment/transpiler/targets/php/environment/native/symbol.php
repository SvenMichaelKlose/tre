// TRE to PHP transpiler
// Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

class __symbol {
	public function __construct ($name, &$pkg)
	{
		$this->n =& $name;
		$this->v = NULL;
		$this->f = NULL;
		$this->p =& $pkg;
	}
    public function __toString ()
    {
        return (($this->p) ? ":" : "") . $this->n;
    }
}

$KEYWORDPACKAGE = new __symbol ("", __w(NULL));
