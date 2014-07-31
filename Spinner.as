/*
	Garden of Bees
	Spinner BadGuy
    
	Author:         Stephen R. Owens - www.studio-owens.com
	Copyright:      Copyright (c) 2014 Stephen R. Owens
	Last Update:    2008-09-05 13:48
	Created:        2008-08-09
*/

class Spinner extends BadGuy {
	private var rotationSpeed:Number = 0;

// Constructor
	public function Spinner(mv:Number, rs:Number, mn:String) {
		myValue = mv;
		myName = mn;
		rotationSpeed = rs;
	}
	
// Public Methods
	public function myAction():Void {
		_root[myName]._rotation += rotationSpeed;
	}
}
