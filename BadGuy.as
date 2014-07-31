/*
	Garden of Bees
	BadGuy
    
	Author:         Stephen R. Owens - www.studio-owens.com
    Copyright:      Copyright (c) 2014 Stephen R. Owens
	Last Update:    2014-07-29 12:51 AM
	Created:        2008-08-09
*/

class BadGuy {
	private var myValue:Number = 0;
	private var myName:String;
	private var testBounds:Object;
	private var myShotType:Number = 0;
	private var myShotMC:String;
	private var myShotSpeed:Number = 0;
	private var myShotName:String;
	private var myShotAngle:Number = 0;
	private var myShotFired:Boolean = false;
	private var numShotsFired:Number = 0;
	private var shotMoved:Number = 0;
	private var shotMaxDistance:Number = 0;
	private var shotReloadSpeed:Number = 0;
	private var meleeStatus:Boolean = false;
	private var meleeCount:Number = 0;
	private var bombDead:Boolean = false;
	private var windBlown:Boolean = false;

// Constructor
	public function BadGuy(mv:Number, mn:String) {
		myValue = mv;
		myName = mn;
	}

// Public Methods
	public function hitTestPlayer():Void {
		for (var i = 1; i<=_root.numHeroes; i++) {
			testBounds = _root["fairy"+i].getBounds(_root);
			
				if (_root[myName].hitTest(testBounds.xMax, _root["fairy"+i]._y, true) 
				|| _root[myName].hitTest(testBounds.xMin, _root["fairy"+i]._y, true)
				|| _root[myName].hitTest(_root["fairy"+i]._x, testBounds.yMax, true)
				|| _root[myName].hitTest(_root["fairy"+i]._x, testBounds.yMin, true)) {
					var shieldUp:Boolean = _root["fairy"+i].fairy.checkShield();
					if (!shieldUp){
						myShotFired = false;
						_root["fairy"+i].fairy.heroDie();
						_root.score += myValue;
					}
				}
		}
		
		hitTestShot();
	}
	
	// Any badguy can shoot stuff
	public function setShooter(stype:Number, mcName:String, speed:Number, md:Number, srs:Number):Void {
		myShotType = stype;
		myShotMC = mcName;
		myShotSpeed = speed;
		shotMaxDistance = md;
		shotReloadSpeed = srs;
		myShotFired = false;
		myShotName = myName+"_"+mcName;
	}
	
	public function shootAction():Void {
		if (bombDead != true) {
			var rndTimeShoot:Number = (Math.random()*100);
			if (rndTimeShoot < shotReloadSpeed && !myShotFired) {
				gunAction();
			}
			if (myShotFired) {
				flingShot();
			}
		}
	}
	
	public function setBombDead(newState:Boolean):Void {
		bombDead = newState;
	}
	
	public function checkBombDead():Boolean {
		return bombDead;
	}
	
	public function setWindBlown(newState:Boolean):Void {
		windBlown = newState;
	}
	
	public function meleeAttack(atkDelay:Number, numFrms:Number) {
		//added the bombDead check here because melee attackers would not explode when in range of explosion
		if (bombDead != true) {
			var rndTimeAttack:Number = (Math.random()*100);
			if (rndTimeAttack < atkDelay && meleeStatus == false) {
				meleeStatus = true;
				_root[myName].gotoAndPlay("meleeAttack");
			}
			if (meleeStatus == true) {
				meleeCount += 1;
				if (meleeCount > numFrms) {
					meleeStatus = false;
					meleeCount = 0;
				}
			}
		}
	}
	
	// Private Methods
	private function gunAction():Void {
		switch (myShotType) {
		case 1 :
			//straight ahead
			myShotAngle = _root[myName]._rotation;
			createShots(1);
			break;
		case 2 :
			//aim and shoot
			break;
		case 3 :
			//multi direction
			myShotAngle = _root[myName]._rotation;
			createShots(4);
			break;
		case 4 :
			//random direction
			break;
		case 5 :
			//light beam
			break;
		case 6 :
			//meele -or- short range
			break;
		default :
			//do nothing
			break;
		}
	}
	
	private function flingShot():Void {
		if (myShotFired) {
			for (var i:Number = 0; i < numShotsFired; i++) {
				var tempAngle:Number = 0;
				tempAngle = myShotAngle+(i*90);
				setProperty(_root[myShotName+i], _rotation, tempAngle);
				_root[myShotName+i]._x = _root[myShotName+i]._x + myShotSpeed*Math.cos(tempAngle*Math.PI/180);
				_root[myShotName+i]._y = _root[myShotName+i]._y + myShotSpeed*Math.sin(tempAngle*Math.PI/180);
				
				//check for remove bullet situation
				shotMoved += myShotSpeed/numShotsFired;
				if (shotMoved > shotMaxDistance) {
					shotMoved = 0;
					hideShot();
				}
				//if (_root[myShotName+i]._x > Stage.width || _root[myShotName+i]._y > Stage.height 
				//|| _root[myShotName+i]._x < 0 || _root[myShotName+i]._y < 0) {
				//	hideShot();
				//}
			}
		} else {
			trace(" ERROR ");
		}
	}
	
	public function hideShot():Void {
		myShotFired = false;
		for (var i:Number = 0; i < numShotsFired; i++) {
			setProperty(_root[myShotName+i], _x, -100);
			setProperty(_root[myShotName+i], _y, -100);
			//removeMovieClip(_root[myShotName]+i);
		}
	}
	
	private function createShots(nsf:Number):Void {
		myShotFired = true;
		if (numShotsFired <= 0) {
			numShotsFired = nsf;
			for (var i:Number = 0; i < numShotsFired; i++) {
				duplicateMovieClip(_root[myShotMC], myShotName+i, _root.getNextHighestDepth()+i);
				setProperty(_root[myShotName+i], _x, _root[myName]._x);
				setProperty(_root[myShotName+i], _y, _root[myName]._y);
				setProperty(_root[myShotName+i], _alpha, 50);
			}
		} else {
			for (var i:Number = 0; i < numShotsFired; i++) {
				setProperty(_root[myShotName+i], _x, _root[myName]._x);
				setProperty(_root[myShotName+i], _y, _root[myName]._y);
				setProperty(_root[myShotName+i], _alpha, 50);
			}
		}
	}
	
	private function hitTestShot():Void {
		//hit test shot
		if (myShotFired == true) {
			for (var j:Number = 0; j < numShotsFired; j++) {
				for (var i = 1; i<=_root.numHeroes; i++) {
					testBounds = _root["fairy"+i].getBounds(_root);
					if (_root[myShotName+j].hitTest(testBounds.xMax, _root["fairy"+i]._y, true) 
					|| _root[myShotName+j].hitTest(testBounds.xMin, _root["fairy"+i]._y, true)
					|| _root[myShotName+j].hitTest(_root["fairy"+i]._x, testBounds.yMax, true)
					|| _root[myShotName+j].hitTest(_root["fairy"+i]._x, testBounds.yMin, true)) {
						var shieldUp:Boolean = _root["fairy"+i].fairy.checkShield();
						if (!shieldUp){
							//myShotFired = false;
							_root["fairy"+i].fairy.heroDie();
							hideShot();
							_root.score += myValue;
						}
						//_root["fairy"+i].fairy.heroDie();
						//hideShot();
						//_root.score += myValue;
					}
				}
			}
		}
	}
	
}
