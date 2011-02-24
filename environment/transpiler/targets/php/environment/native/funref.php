// TRE to PHP transpiler
// Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

class __funref {
    var $n;
    var $g;

	public function __construct ($name, $ghost)
	{
		$this->n = $name;
		$this->g = $ghost;
        return $this;
	}
}
