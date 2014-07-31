/*
	Garden of Bees
	Magic or Hero Abilities
    
	Author:         Stephen R. Owens - www.studio-owens.com
    Copyright:      Copyright (c) 2014 Stephen R. Owens
	Last Update:    2014-07-29 12:51 AM
	Created:        2008-11-03
*/

class Magic extends Collectable {
	private var magicType:String;
	private var myTargets:Array = new Array();
	private var targetAnimation:String; //the frame of the target object to goto with magic cast
	private var growAdultStatus:Boolean = false; //is this magic flower in the adult stage, magic only works in adult stage
	private var startGrowTime:Date;
	private var nowGrowTime:Date;
	private var elapsedTime:Number = 0;
	private var growLength:Number = 0; //number of seconds till regrow happens
	private var growAnimation:String; //the frame to goto to grow the spell
	private var castAnimation:String; //the frame to goto to cast the spell
	private var numberOfBombs:Number = 0; // the number of bombs on the screen
	private var bombExplodeZone:Number = 0;
	private var deadTargets:Array = new Array();
	private var windShotName:String;
	private var numWindShots:Number = 0;
	private var windBlowOffDist:Number = 0;
	private var vineCurlUsed:Boolean = false;
	private var timedShieldWarning:Boolean = false;
	
// Constructor
	public function Magic(mValue:Number, mType:String, targetsArr:Array, mName:String) {
		myValue = mValue;
		magicType = mType;
		myTargets = targetsArr;
		targetAnimation = "magicAction";
		castAnimation = "castMe";
		growAnimation = "growMe";
		pickUpDistance = 20;
		myName = mName;
		growAdultStatus = true;
		growLength = 6;
		if (magicType == "bomb") {
			setNumberOfBombs(1, 200);
		}
		if (magicType == "wind") {
			setWindShots(4, "flowerWindShot");
			setWindBlowOffDist(50);
		}
	}
	
// Public Methods
	public function setTragetAnimation(tfName:String):Void {
		targetAnimation = tfName;
	}
	
	public function setWindBlowOffDist(dist:Number):Void {
		windBlowOffDist = dist;
	}
	
	public function setNumberOfBombs(nb:Number, bz:Number):Void {
		numberOfBombs = nb;
		var mt:Number = myTargets.length; 
		var i:Number = 0;
		for (i = 0; i < mt; i++) {
			deadTargets[i] = 0;
		}
		bombExplodeZone = bz;
	}
	
	public function setGrowLength(gNum:Number):Void {
		growLength = gNum;
	}
	
	public function myAction():Void {
		//do not regrow if grow length is set to zero
		if (growLength >= 1) {
			growMe();
		}
	}
	
	public function levelChangeCleanUp():Void {
		//check and reset hero shrink and timedShield
		for (var i = 1; i<=_root.numHeroes; i++) {
			
			//turn off shrink if active
			var tempBool:Boolean = _root["fairy"+i].fairy.getShrinkStatus();
			if (tempBool == true) {
				_root["fairy"+i].fairy.setShrinkStatus(false);
				var tempW:Number = _root["fairy"+i]._width;
				var tempH:Number = _root["fairy"+i]._height;
				_root["fairy"+i]._width = tempW*4;
				_root["fairy"+i]._height = tempH*4;
			}
			
			//turn off timed sheild if active
			var tempBool2:Boolean = _root["fairy"+i].fairy.getTimedShieldActive();
			if (tempBool2 == true) {
				_root["fairy"+i].fairy.toggleShield();
				_root["fairy"+i].fairy.setTimedShieldActive(false);
				_root["heroShield"]._x = -200;
				_root["heroShield"]._y = -200;
				_root["heroShield"].gotoAndStop("idle");
			}
			
			//do not allow carry over of shield charges from one level to the next
			_root["fairy"+i].fairy.setShieldCharges(0);
		}
		
		windCleanUp();
	}
	
// Private Methods
	//overridden pickMeUp from Collectable
	private function pickMeUp():Void {
		//only allow magic cast if an adult plant
		if (growAdultStatus == true) {
			_root[myName].gotoAndPlay(castAnimation);
			
			switch (magicType) {
				case "bomb":
				    _root.soundMagicBomb.start();
					bombCastSpell();
					break;
				case "coin":
					_root.soundMagicCoin.start();
					coinCastSpell();
					break;
				case "portal":
				    _root.soundMagicPortal.start();
					portalCastSpell();
					break;
				case "shield":
					_root.soundMagicShield.start();
					shieldCastSpell();
					break;
				case "shrink":
					_root.soundMagicShrink.start();
					shrinkCastSpell();
					break;
				case "timedshield":
					_root.soundMagic.start();
					timedshieldCastSpell();
					break;
				case "vinecurl":
				    _root.soundMagicVinecurl.start();
					vinecurlCastSpell();
					break;
				case "wind":
					_root.soundMagicWind.start();
					windCastSpell();
					break;
				default:
					trace("ERROR: Spell undefined");
			}
			
			_root.score += myValue; // add to score
			startGrowTime = new Date();
			growAdultStatus = false;
			myValue = 0; //this spell will only add to the score one time
		}
	}
	
	private function growMe():Void {
		if (growAdultStatus == false) {
			nowGrowTime =  new Date();
			elapsedTime = Math.floor((nowGrowTime.getTime() - startGrowTime.getTime())/1000); //whole seconds of elapsed time
			
			// plant a seed
			if (elapsedTime == growLength-1) {
				_root[myName].gotoAndPlay(growAnimation);
				
				switch (magicType) {
					//regrow bomb pods if this is a flowerBomb
					case "bomb":
						bombDeadCheck();
						break;
					case "timedshield":
						timedShieldCheck();
						break;
				}
				
			}
			
			//spell effects during grow period
			switch (magicType) {
				case "timedshield":
					moveTimedShield();
					break;
				case "wind":
					moveWind();
					break;
			}
			
			//adult plant stop growing and stop spell effects
			if (elapsedTime > growLength) {
				growAdultStatus = true; 
				
				//finish spell effects
				switch (magicType) {
					case "shrink":
						shrinkCleanUp();
						break;
					case "timedshield":
						timedShieldCleanUp();
						break;
					case "wind":
						windCleanUp();
						break;
				}
				
			}
		}
	}
	
	private function setWindShots(ns:Number, clipName:String):Void {
		//setup all the wind shot bullets
		windShotName = clipName;
		numWindShots = ns;
		var i:Number = 0;
		for (i = 0; i < numWindShots; i++) {
			duplicateMovieClip(_root[windShotName], windShotName+i, _root.getNextHighestDepth()+i);
			setProperty(_root[windShotName+i], _x, -500);
			setProperty(_root[windShotName+i], _y, -500);
			setProperty(_root[windShotName+i], _alpha, 50);
		}
	}
	
	private function shrinkCleanUp():Void {
		var mt:Number = myTargets.length; 
		var i:Number = 0;
		var targetName:String;
		//grow fairy
		for (i = 0; i < mt; i++) {
			targetName = myTargets[i];
			var tempW:Number = _root[targetName]._width;
			var tempH:Number = _root[targetName]._height;
			_root[targetName]._width = tempW*4;
			_root[targetName]._height = tempH*4;
			_root[targetName].fairy.setShrinkStatus(false);
		}
	}
	
	private function timedShieldCleanUp():Void {
		var mt:Number = myTargets.length; 
		var i:Number = 0;
		var targetName:String;
		//end timed shield
		for (i = 0; i < mt; i++) {
			targetName = myTargets[i];
			_root[targetName].fairy.toggleShield();
			_root["heroShield"]._x = -200;
			_root["heroShield"]._y = -200;
			timedShieldWarning = false;
			_root["heroShield"].gotoAndStop("idle");
		}
	}
	
	private function windCleanUp():Void {
		// remove wind shots from play area
		var i:Number = 0;
		for (i = 0; i < numWindShots; i++) {
			setProperty(_root[windShotName+i], _x, -500);
			setProperty(_root[windShotName+i], _y, -500);
		}
		var j:Number = 0;
		for (j = 0; j < myTargets.length; j++) {
			var targetName:String = myTargets[j];
			//_root[targetName].badGuy.setWindBlown(false);
		}
	}
	
	private function moveWind():Void {
		//move wind
		var i:Number = 0;
		for (i = 0; i < numWindShots; i++) {
			_root[windShotName+i]._x -= 50;
			//move targets with wind
			var mt:Number = myTargets.length; 
			var targetName:String;
			var j:Number = 0;
			for (j = 0; j < mt; j++) {
				targetName = myTargets[j];
				if ((_root[targetName]._x > _root[windShotName+i]._x) 
					&& (_root[targetName]._y > _root[windShotName+i]._y-50)
					&& (_root[targetName]._y < _root[windShotName+i]._y+50)) {
					_root[targetName]._x -= 50;
					_root[targetName].badGuy.setWindBlown(true);
				}
			}
		}
	}
	
	private function moveTimedShield():Void {
		var mt:Number = myTargets.length; 
		var i:Number = 0;
		var targetName:String;
		// position shield
		for (i = 0; i < mt; i++) {
			targetName = myTargets[i];
			var tempX:Number = _root[targetName]._x;
			var tempY:Number = _root[targetName]._y;
			_root["heroShield"]._x = tempX;
			_root["heroShield"]._y = tempY;
		}
	}
	
	private function timedShieldCheck():Void {
		if (timedShieldWarning == false) {
			timedShieldWarning = true;
			_root["heroShield"].gotoAndPlay("blinkShield");
		}
	}
	
	private function bombDeadCheck():Void {
		var i:Number = 0;
		var targetName:String;
		//regrow all bomb pods
		for (i = 0; i < numberOfBombs; i++) {
			targetName = myTargets[i];
			_root[targetName].gotoAndPlay(growAnimation);
		}
		//move old targets off stage, if they are bouncers then they will auto reapear at their start locations
		var mt:Number = myTargets.length; 
		for (i = numberOfBombs; i < mt; i++) {
			targetName = myTargets[i];
			if (deadTargets[i] == 1) {
				_root[targetName]._x=-200;
				_root[targetName]._y=-200;
			}
		}
	}
	
	private function windCastSpell():Void {
		var i:Number = 0;
		for (i = 0; i < numWindShots; i++) {
			_root[windShotName+i]._x = 800+(45*i);
			_root[windShotName+i]._y = ((600/numWindShots)*(i+1));
		}
	}
	
	private function vinecurlCastSpell():Void {
		var mt:Number = myTargets.length; 
		var i:Number = 0;
		var targetName:String;
		//double coin values
		if (vineCurlUsed == false) {
			for (i = 0; i < mt; i++) {
				targetName = myTargets[i];
				_root[targetName].gotoAndPlay(targetAnimation);
			}
			vineCurlUsed = true;
		}
	}
	
	private function timedshieldCastSpell():Void {
		var mt:Number = myTargets.length; 
		var i:Number = 0;
		var targetName:String;
		//setup the shield status of the hero
		for (i = 0; i < mt; i++) {
			targetName = myTargets[i];
			_root[targetName].fairy.toggleShield();
			_root[targetName].fairy.setTimedShieldActive(true);
		}
	}
	
	private function shrinkCastSpell():Void {
		var mt:Number = myTargets.length; 
		var i:Number = 0;
		var targetName:String;
		//shrink the fairies
		for (i = 0; i < mt; i++) {
			targetName = myTargets[i];
			var tempW = _root[targetName]._width;
			var tempH = _root[targetName]._height;
			_root[targetName]._width = tempW/4;
			_root[targetName]._height = tempH/4;
			_root[targetName].fairy.setShrinkStatus(true);
		}
	}
	
	private function shieldCastSpell():Void {
		var mt:Number = myTargets.length; 
		var i:Number = 0;
		var targetName:String;
		//add single use shield charges to fairy
		for (i = 0; i < mt; i++) {
			targetName = myTargets[i];
			_root[targetName].fairy.setShieldCharges(1);
		}
	}
	
	private function portalCastSpell():Void {
		var mt:Number = myTargets.length; 
		var i:Number = 0;
		var targetName:String;
		//expand portal
		for (i = 0; i < mt; i++) {
			targetName = myTargets[i];
			_root[targetName].portal.setDistToExit(_root[targetName].portal.getDistToExit()*5);
			_root[targetName]._width *=3;
			_root[targetName]._height *=3;
		}
	}
	
	private function coinCastSpell():Void {
		var mt:Number = myTargets.length; 
		var i:Number = 0;
		var targetName:String;
		//double coin values
		for (i = 0; i < mt; i++) {
			targetName = myTargets[i];
			_root[targetName].coin.doubleValue();
			_root[targetName].gotoAndPlay(targetAnimation);
		}
	}
	
	private function bombCastSpell():Void {
		var mt:Number = myTargets.length; 
		var i:Number = 0;
		var bombName:String;
		var targetName:String;
		//explode bombs
		for (i = 0; i < numberOfBombs; i++) {
			bombName = myTargets[i];
			_root[bombName].gotoAndPlay(targetAnimation);
			//explode enemies
			var j:Number = 0;
			//j = number of bombs because that is the offset into the array of bombpods and enemies
			for (j = numberOfBombs; j < mt; j++) {
				targetName = myTargets[j];
				if ( (_root[targetName]._x <= (_root[bombName]._x + bombExplodeZone)) 
				&& (_root[targetName]._x >= (_root[bombName]._x - bombExplodeZone)) 
				&& (_root[targetName]._y <= (_root[bombName]._y + bombExplodeZone))
				&& (_root[targetName]._y >= (_root[bombName]._y - bombExplodeZone)) 
				) {
					//any melee badguys to explode must have an object named badguy
					//  for example, if you have a bouncer it should be declaired like:
					//  var badGuy:Bouncer = new Bouncer(-15, 4, "random", 8, this._name);
					_root[targetName].badGuy.setBombDead(true);
					//added boss here, but really all bosses could have their object named badGuy instead
					_root[targetName].boss.setBombDead(true);
					//add to dead targets and explode
					deadTargets[j] = 1;
					_root[targetName].gotoAndPlay(targetAnimation);
				}
			}
		}
	}
}