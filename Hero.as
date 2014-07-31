/*
	Garden of Bees
	Hero
    
	Author:         Stephen R. Owens - www.studio-owens.com
	Copyright:      Copyright (c) 2014 Stephen R. Owens
	Last Update:    2009-01-08 18:12
	Created:        2008-08-09
*/

class Hero {
	private var plrState:String;
	private var plrX:Number = 0;
	private var plrY:Number = 0;
	private var myName:String;
	private var myDeathName:String;
	private var numDeathMC:Number = 0;
	private var theClicks:Number = 0;
	private var spiritAngle:Number = 0;
	private var spiritMove:Boolean = false;
	private var shield:Boolean = false;
	private var shieldCharges:Number = 0;
	private var startShieldTime:Date;
	private var nowShieldTime:Date;
	private var shieldActive:Boolean = false;
	private var shieldFailure:Boolean = false;
	private var shrinkStatus:Boolean = false;
	private var timedShieldActive:Boolean = false;
	
// Constructor
	public function Hero(mName:String) {
		myName = mName;
		
		plrState = "idle";
		_root[myName].gotoAndPlay("stand");
	}
	
// Public Methods

	public function clickMe():Void {
		if (plrState == "idle") {
			if (_root[myName].hitTest(_root._xmouse, _root._ymouse)) {
				Mouse.hide();
				startDrag(_root[myName], true);
				_root[myName].gotoAndPlay("fly");
				plrState = "move";
			}
		} else if (plrState == "move") {
			Mouse.show();
			stopDrag();
			_root[myName].gotoAndPlay("stand");
			plrState = "idle";
		} 
	}
	
	public function myAction():Void {
		//check status of one hit shield and update as needed
		if (shieldActive == true) {
			shieldCheck();
		}
	}
	
	public function jaysMagic():Void {
		stopDrag();
		Mouse.show();
		_root[myName].gotoAndPlay("stand");
		plrState = "idle";
		setProperty(_root[myName], _x, plrX);
		setProperty(_root[myName], _y, plrY);
		_root.thisGame.addR();
	}
	
	public function setShieldCharges(sc:Number):Void {
		shieldCharges = sc;
	}
	
	public function toggleShield():Void {
		if (!shield) {
			shield = true;
			timedShieldActive = true;
			//trace("God Mode");
		} else {
			shield = false;
			timedShieldActive = false;
			//trace("Normal Mode");
		}
	}

	public function moveHeroSpirit():Void {
		var speed:Number = 14;
		if (spiritMove == true) {
			var distX:Number = plrX - _root["heroSpirit"]._x;
			var distY:Number = plrY - _root["heroSpirit"]._y;
			
			spiritAngle = Math.atan2(distY, distX);
			_root["heroSpirit"]._rotation = spiritAngle/Math.PI*180;
			
			if ((Math.abs(distX) + Math.abs(distY)) <= speed+2) {
				_root["heroSpirit"].gotoAndPlay("explode");
				spiritMove = false;
				setProperty(_root[myName], _alpha, 100);
				//set alive fairy mist
				//var rndFrame:Number = Math.floor(Math.random()*3)+1;
				//setProperty(_root["heroMist2"], _x, plrX);
				//setProperty(_root["heroMist2"], _y, plrY);
				//setProperty(_root["heroMist2"], _alpha, 50);
				//_root["heroMist2"].gotoAndPlay(rndFrame);
				//make sure comet is off
			}
			
			_root["heroSpirit"]._x = _root["heroSpirit"]._x + speed*Math.cos(spiritAngle);
			_root["heroSpirit"]._y = _root["heroSpirit"]._y + speed*Math.sin(spiritAngle);
		}
	}
	
	public function findStart():Void {
		plrX = getProperty(_root["startPortal"], _x);
		plrY = getProperty(_root["startPortal"], _y);
		stopDrag();
		Mouse.show();
		_root[myName].gotoAndPlay("stand");
		plrState = "idle";
		setProperty(_root[myName], _x, plrX);
		setProperty(_root[myName], _y, plrY);
	}
	
	public function checkShield():Boolean {
		
		if (!shield) {
			// start portal is base
			if ((_root[myName]._x <= (plrX + 5) && _root[myName]._x >= (plrX - 5) ) &&
				(_root[myName]._y <= (plrY + 5) && _root[myName]._y >= (plrY - 5))) {
				return true;
			// check for temporary one use shield
			} else if (shieldCharges > 0) {
				// use shield
				setProperty(_root["heroShield"], _x, _root[myName]._x);
				setProperty(_root["heroShield"], _y, _root[myName]._y);
				_root["heroShield"].gotoAndStop("idle");
				shieldCharges -= 1;
				startShieldTime = new Date();
				shieldActive = true;
				return true;
			// check to see if hero is in the shield
			} else if ((_root[myName]._x <= (_root["heroShield"]._x + 20) && _root[myName]._x >= (_root["heroShield"]._x - 20) ) &&
				(_root[myName]._y <= (_root["heroShield"]._y + 20) && _root[myName]._y >= (_root["heroShield"]._y - 20))) {
				return true;
			// no shield	
			} else {
				return false;
			}
		// shield is up 
		} else {
			return true;
		}
	}
	
	public function setShrinkStatus(tf:Boolean):Void {
		shrinkStatus = tf;
	}
	
	public function getShrinkStatus():Boolean {
		return shrinkStatus;
	}
	
	public function setTimedShieldActive(tf:Boolean):Void {
		timedShieldActive = tf;
	}
	
	public function getTimedShieldActive():Boolean {
		return timedShieldActive;
	}
	
// Private Methods
	private function shieldCheck():Void {
		nowShieldTime=  new Date();
		var elapsedTime:Number = Math.floor((nowShieldTime.getTime() - startShieldTime.getTime())/1000); //whole seconds of elapsed time
		if (elapsedTime == 2 && shieldFailure == false) {
			//show shield is about to fail
			shieldFailure = true; //shield is about to fail
			_root["heroShield"].gotoAndPlay("blinkShield");
		} 
		if (elapsedTime == 3) {
			//result shield
			_root["heroShield"].gotoAndStop("idle");
			_root["heroShield"]._x = -200;
			_root["heroShield"]._y = -200;
			shieldActive = false; //shield is no longer active
			shieldFailure = false; //shield is not about to fail cause it doesn't exist anymore
		}
	}

	private function heroDie():Void {
		
		stopDrag();
		
		spiritMove = true;
		
		// play hero die sound
        _root.soundHeroDie.start();
		
		// get mouse position
		var tempX = _root[myName]._x;
		var tempY = _root[myName]._y;
		
		//reset fairy
		setProperty(_root[myName], _x, plrX);
		setProperty(_root[myName], _y, plrY);
		setProperty(_root[myName], _alpha, 0);
		
		setProperty(_root["heroMist2"], _alpha, 15);
		
		_root["heroSpirit"]._x = tempX;
		_root["heroSpirit"]._y = tempY;
		_root["heroSpirit"].gotoAndPlay("fly");
		
		// show mouse
		Mouse.show();
		
		_root[myName].gotoAndPlay("stand");
		plrState = "idle";
		
		//setup dead fairy mist
		var rndFrame:Number = Math.floor(Math.random()*50)+1;
		setProperty(_root["heroMist1"], _x, tempX);
		setProperty(_root["heroMist1"], _y, tempY);
		setProperty(_root["heroMist1"], _alpha, 50);
		_root["heroMist1"].gotoAndPlay(rndFrame);
	}
}
