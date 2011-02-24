// TRE to PHP transpiler
// Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

class __character {
    var $v;

	public function __construct ($num)
	{
		$this->v = $num;
        return $this;
	}

	public function __toString ()
	{
        return "#\\" . chr ($this->v) . " ";
	}
}
