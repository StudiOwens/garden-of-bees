/*
	Garden of Bees
	Collectable by the Hero
    
	Author:         Stephen R. Owens - www.studio-owens.com
        Copyright:      Copyright (c) 2014 Stephen R. Owens
	License:        The MIT License (MIT)
	Last Update:    2009-01-07 20:36
	Created:        2008-08-09
*/

class Collectable {
	private var myValue:Number = 0;
	private var myName:String;
	private var pickUpDistance:Number = 0;
	
// Constructor
	public function Collectable(mValue:Number, mName:String) {
		myValue = mValue;
		myName = mName;
		pickUpDistance = 15;
	}
	
// Public Methods
	public function hitTestPlayer():Void {
		for (var i=1; i<=_root.numHeroes; i++) {
			if ( (_root[myName]._x <= (_root["fairy"+i]._x + pickUpDistance)) 
			&& (_root[myName]._x >= (_root["fairy"+i]._x - pickUpDistance)) 
			&& (_root[myName]._y <= (_root["fairy"+i]._y + pickUpDistance))
			&& (_root[myName]._y >= (_root["fairy"+i]._y - pickUpDistance)) 
			) {
				pickMeUp();
			}
		}
	}
	
	public function setPickUpDistance(pd:Number):Void {
		pickUpDistance = pd;
	}
	
	public function doubleValue():Void {
		myValue = myValue * 2;
	}
	
// Private Methods
	private function pickMeUp():Void {
		setProperty(_root[myName], _x, -100);
		setProperty(_root[myName], _y, -100);
		_root.score += myValue; // add to score
		// pickup sound for collectables, over ridden in Magic for those sounds
		_root.soundPickup.start();
	}
}
