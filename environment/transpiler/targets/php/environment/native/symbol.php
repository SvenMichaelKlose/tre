// TRE to PHP transpiler
// Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

class __symbol {
	public function &__construct ($name, &$pkg)
	{
		$this->n =& $name;
		$this->v =& __w(NULL);
		$this->f =& __w(NULL);
		$this->p =& $pkg;
        return $this;
	}

    public function __toString ()
    {
        return (($this->p) ? ":" : "") . $this->n;
    }
}

$KEYWORDPACKAGE =& new __symbol ("", __w(NULL));
