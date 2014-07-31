/*
	Garden of Bees
	Bouncer BadGuy
    
	Author:         Stephen R. Owens - www.studio-owens.com
    Copyright:      Copyright (c) 2014 Stephen R. Owens
	Last Update:    2014-07-29 12:51 AM
	Created:        2008-08-09
*/

class Bouncer extends BadGuy {
	private var bounceSpeed:Number = 0;
	private var travel:String;
	private var testMyBounds:Object;
	private var turning:Boolean = false; 
	private var outOfBounds:Boolean = false;
	private var bounceMethod:Number; // 0 = default direct bounce, 1 = half bounce, 2 = full random bounce
	private var amtTurned:Number = 0;
	private var turnRate:Number = 0;
	private var randomXspeed:Number = 0;
	private var randomYspeed:Number = 0;
	private var startX:Number = 0;
	private var startY:Number = 0;
	private var nowX:Number = 0;
	private var nowY:Number = 0;
	private var futureX:Number = 0;
	private var futureY:Number = 0;
	private var distX:Number = 0;
	private var distY:Number = 0;
	private var travelAngle:Number = 0;
	private var currentAngle:Number = 0;
	private var rotateDirection:Number = 0;
	private var distOfAngles:Number = 0;
	

// Constructor
	public function Bouncer(mv:Number, bs:Number, trvl:String, tr:Number, mn:String) {
		myValue = mv;
		bounceSpeed = bs;
		travel = trvl;
		myName = mn;
		turnRate = tr;
		if (travel == "random" || travel == "pong") {
			startX = _root[myName]._x;
			startY = _root[myName]._y;
			randomXspeed = bounceSpeed;
			randomYspeed = bounceSpeed;
			turning = true;
			if (travel == "random") {
				bounceMethod = 2;
			} else if (travel == "pong") {
				bounceMethod = 1;
			}
		} else {
			bounceMethod = 0;
			switch(travel) {
				case "down":
					_root[myName]._rotation = 90;
					break;
				case "left":
					_root[myName]._rotation = 180;
					break;
				case "up":
					_root[myName]._rotation = 270;
					break;
				case "right":
				default:
					_root[myName]._rotation = 0;
			}
		}
	}
	
// Public Methods
	public function myAction():Void {
		if (turning == true) {
			turnMeAround();
		}
		
		moveMeForward();
		
		if (turning == false || travel == "pong" || travel == "random") {
			collision();
		}
		
		if (_root[myName]._x > Stage.width || _root[myName]._y > Stage.height || _root[myName]._x < 0 || _root[myName]._y < 0) {
			if (bombDead != true) {
				returnToSender();
			}
		}
	}
	
	public function setDirection(d:String):Void {
		travel = d;
	}
	
	public function setBounceMethod(bm:Number):Void {
		bounceMethod = bm;
	}
	
// Private Methods
	private function collision():Void {
		testMyBounds = _root[myName].getBounds(_root);
		if (travel != "random" && travel != "pong") {
			if (_root.walls.hitTest(testMyBounds.xMax, _root[myName]._y, true) 
			 || _root.walls.hitTest(testMyBounds.xMin, _root[myName]._y, true) 
			 || _root.walls.hitTest(_root[myName]._x, testMyBounds.yMax, true) 
			 || _root.walls.hitTest(_root[myName]._x, testMyBounds.yMin, true)) {
				turning = true;
				bounceBack();
			}
		} else {
			if (_root.walls.hitTest(testMyBounds.xMax, _root[myName]._y, true)) {
				turning = true;
				bounceBackAdv(0);
			} else if (_root.walls.hitTest(testMyBounds.xMin, _root[myName]._y, true)) {
				turning = true;
				bounceBackAdv(1);
			} else if (_root.walls.hitTest(_root[myName]._x, testMyBounds.yMax, true)) {
				turning = true;
				bounceBackAdv(2);
			} else if (_root.walls.hitTest(_root[myName]._x, testMyBounds.yMin, true)) {
				turning = true;
				bounceBackAdv(3);
			}
		}
	}
	
	private function bounceBack():Void {
		switch (travel) {
			case "left":
				_root[myName]._x += bounceSpeed;
				travel = "right";
				break;
			case "right":
				_root[myName]._x -= bounceSpeed;
				travel = "left";
				break;
			case "up":
				_root[myName]._y += bounceSpeed;
				travel = "down";
				break;
			case "down":
				_root[myName]._y -= bounceSpeed;
				travel = "up";
				break;
			default:
				trace (travel + " ERROR " + myName + ": on travel driection chage ");
		}
	}
	
	private function bounceBackAdv(hitLoc:Number):Void {
		switch (hitLoc) {
			case 0:
				amtTurned = 0;
				_root[myName]._x -= bounceSpeed;
				if (bounceMethod == 2) {
					_root[myName]._y += (randomYspeed * -1);
				}
				randomXspeed *= -1;
				if (travel == "random") {
					randomYspeed = (Math.floor(Math.random() * bounceSpeed) + 1);
					if (Math.random() * 2 > 1) {
						randomYspeed = (Math.floor(Math.random() * bounceSpeed) + 1) *-1;
					}
				}
				break;
			case 1:
				amtTurned = 0;
				_root[myName]._x += bounceSpeed;
				if (bounceMethod == 2) {
					_root[myName]._y += (randomYspeed * -1);
				}
				randomXspeed *= -1;
				if (travel == "random") {
					randomYspeed = (Math.floor(Math.random() * bounceSpeed) + 1);
					if (Math.random() * 2 > 1) {
						randomYspeed = (Math.floor(Math.random() * bounceSpeed) + 1) *-1;
					}
				}
				break;
			case 2:
				amtTurned = 0;
				_root[myName]._y -= bounceSpeed;
				if (bounceMethod == 2) {
					_root[myName]._x += (randomXspeed * -1);
				}
				if (travel == "random") {
					randomXspeed = (Math.floor(Math.random() * bounceSpeed) + 1);
					if (Math.random() * 2 > 1) {
						randomXspeed = (Math.floor(Math.random() * bounceSpeed) + 1) *-1;
					}
				}
				randomYspeed *= -1;
				break;
			case 3:
				amtTurned = 0;
				_root[myName]._y += bounceSpeed;
				if (bounceMethod == 2) {
					_root[myName]._x += (randomXspeed * -1);
				}
				if (travel == "random") {
					randomXspeed = (Math.floor(Math.random() * bounceSpeed) + 1);
					if (Math.random() * 2 > 1) {
						randomXspeed = (Math.floor(Math.random() * bounceSpeed) + 1) *-1;
					}
				}
				randomYspeed *= -1;
				break;
		}
	}
	
	private function moveMeForward():Void {
		switch (travel) {
			case "left":
				_root[myName]._x -= bounceSpeed;
				break;
			case "right":
				_root[myName]._x += bounceSpeed;
				break;
			case "up":
				_root[myName]._y -= bounceSpeed;
				break;
			case "down":
				_root[myName]._y += bounceSpeed;
				break;
			case "random":
			case "pong":
				_root[myName]._x += randomXspeed;
				_root[myName]._y += randomYspeed;
				break;
			default:
				trace (travel + " ERROR " + myName + ": on movement " );
		}
	}
	
	private function turnMeAround():Void {
		switch (travel) {
			case "random":
			case "pong":
				if (amtTurned <= 0) {
					nowX = _root[myName]._x;
					nowY = _root[myName]._y;
					futureX = nowX + randomXspeed;
					futureY = nowY + randomYspeed;
					distX = futureX - nowX;
					distY = futureY - nowY;
					travelAngle = Math.atan2(distY, distX);
					travelAngle = Math.floor(travelAngle * (180/Math.PI));
				}
				
				currentAngle = _root[myName]._rotation;
				distOfAngles = travelAngle - currentAngle;
				
				//choose the shortest turning direction
				if (distOfAngles > 180) {
					distOfAngles -= 360;
				} else if (distOfAngles < -180) {
					distOfAngles += 360;
				}
				
				//set the turn speed
				var rotateAmount:Number = 0;
				if (distOfAngles >= 135 || distOfAngles <= -135) {
					rotateAmount = turnRate * 4;
				} else if (distOfAngles >= 135 || distOfAngles <= -135) {
					rotateAmount = turnRate * 3;
				} else if (distOfAngles >= 90 || distOfAngles <= -90) {
					rotateAmount = turnRate * 2;
				} else {
					rotateAmount = turnRate;
				}
				
				//set the turn amount
				if (distOfAngles < -rotateAmount) {
					distOfAngles =- rotateAmount;
				}
				if (distOfAngles > rotateAmount) {
					distOfAngles = rotateAmount;
				}
				
				//turn
				_root[myName]._rotation += distOfAngles;
				
				//currentAngle = _root[myName]._rotation;
				
				//distOfAngles = travelAngle - currentAngle;
				//rotateDirection = distOfAngles/Math.abs(distOfAngles);
				
				//if (distOfAngles >= 180) {
				//	rotateDirection *= -2;
				//} else if (distOfAngles <= -180) {
				//	rotateDirection *= -2;
				//}
				
				//_root[myName]._rotation += turnRate * rotateDirection;
				amtTurned += 1;
				
				if(Math.abs(distOfAngles) < turnRate){
					_root[myName]._rotation = travelAngle;
					amtTurned = 0;
					turning = false;
				}
				break;
			default:
				_root[myName]._rotation += turnRate;
				amtTurned += turnRate;
				if (amtTurned >= 180) {
					amtTurned = 0;
					turning = false;
				}
		}
	}
	
	private function returnToSender():Void {
		if (windBlown == false) {
			_root[myName]._x = startX;
			_root[myName]._y = startY;
		}
		//outOfBounds = true;
	}
}