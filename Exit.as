/*
	Garden of Bees
	Exit Portal
    
	Author:         Stephen R. Owens - www.studio-owens.com
    Copyright:      Copyright (c) 2014 Stephen R. Owens
	Last Update:    2008-09-24 13:40
	Created:        2008-08-09
*/

class Exit {
	private var myValue:Number = 0;
	private var myName:String;
	private var testsPassed:Number = 0;
	private var exitDistance:Number = 0;
	private var nextLevel:String;
	
// Constructor
	public function Exit(mValue:Number, distNum:Number, nxtLvl:String, mName:String) {
		myValue = mValue;
		myName = mName;
		exitDistance = distNum;
		nextLevel = nxtLvl;
	}
	
// Public Methods
	public function hitTestPlayer():Void {
		for (var i=1; i<=_root.numHeroes; i++) {
			if ( (_root[myName]._x <= (_root["fairy"+i]._x + exitDistance)) 
			&& (_root[myName]._x >= (_root["fairy"+i]._x - exitDistance)) 
			&& (_root[myName]._y <= (_root["fairy"+i]._y + exitDistance))
			&& (_root[myName]._y >= (_root["fairy"+i]._y - exitDistance)) 
			) {
				testsPassed += 1;
			}
			/*if (_root[myName].hitTest(_root["fairy"+i])) {
				testsPassed += 1;
			}*/
		}
		if (testsPassed == _root.numHeroes) {
			_root["fairy"+i].fairy.clickMe();
			
			// exit portal sound
			_root.soundExit.start();
			
			levelFinished();
		} else {
			testsPassed = 0;
		}
	}
	
	public function setDistToExit(d:Number):Void {
		exitDistance = d;
	}
	
	public function getDistToExit():Number {
		return exitDistance;
	}
	
// Private Methods
	private function levelFinished():Void {
		_root.thisGame.addScore(_root.score);
		_root.score = _root.thisGame.getScore();
		_root.gotoAndPlay(nextLevel);
	}
}