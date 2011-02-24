// TRE to PHP transpiler
// Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

class __symbol {
    var $n;
    var $v;
    var $f;
    var $p;

	public function __construct ($name, $pkg)
	{
		$this->n = $name;
		$this->v = NULL;
		$this->f = NULL;
		$this->p = $pkg;
        return $this;
	}

    public function __toString ()
    {
        return (($this->p) ? ":" : "") . $this->n;
    }
}

$KEYWORDPACKAGE = new __symbol ("", NULL);
