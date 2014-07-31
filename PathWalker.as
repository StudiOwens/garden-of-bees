/*
	Garden of Bees
	PathWalker BadGuy
    
	Author:         Stephen R. Owens - www.studio-owens.com
    Copyright:      Copyright (c) 2014 Stephen R. Owens
	Last Update:    2009-02-13 13:07
	Created:        2008-09-07
*/

class PathWalker extends BadGuy {
	private var speed:Number = 0;
	private var nextWayPoint:Number = 0;
	private var wayPointsX:Array = new Array();
	private var wayPointsY:Array = new Array();
	private var travelAngle:Number = 0;
	private var currentAngle:Number = 0;
	private var distOfAngles:Number = 0;
	private var rotateAmount:Number = 0;
	private var distX:Number = 0;
	private var distY:Number = 0;
	private var direction:String; //oneway, loop, random
	private var pathLength:Number = 0;
	private var turnRate:Number = 0;
	

// Constructor
	public function PathWalker(mv:Number, sp:Number, d:String, pXarr:Array, pYarr:Array, mName:String) {
		myValue = mv;
		speed = sp;
		direction = d;
		wayPointsX = pXarr;
		wayPointsY = pYarr;
		myName = mName;
		_root[myName]._x = getPointX(0);
		_root[myName]._y = getPointY(0);
		nextWayPoint++;
		pathLength = wayPointsX.length;
		turnRate = speed * 3;
		//turning = true;
	}
	
// Public Methods
	public function myAction():Void {
		checkWayPoints();
		moveMeForward();
		turnMeAround2();
	}
	
	public function getPointX(position:Number):Number {
		return wayPointsX[position];
	}
	
	public function getPointY(position:Number):Number {
		return wayPointsY[position];
	}
	
// Private Methods
	private function checkWayPoints():Void {
		if (( nextWayPoint + 1 > pathLength ) && (direction != "random") ) {
			if (direction == "loop") {
				//set to the begining waypoint
				nextWayPoint = 0;
			} else if (direction == "oneway") {
				//move directly to the begining of the path, do not pass go
				_root[myName]._x = getPointX(0);
				_root[myName]._y = getPointY(0);
				nextWayPoint = 0;
			}
		}
	}

	private function moveMeForward():Void {
		distX = getPointX(nextWayPoint) - _root[myName]._x;
		distY = getPointY(nextWayPoint) - _root[myName]._y;
		
		if ((Math.abs(distX) + Math.abs(distY)) < speed) {
			//turning = true;
			if (direction != "random") {
				nextWayPoint++;
			} else {
				//choose random waypoint
				var tempWayPoint:Number = nextWayPoint;
				var tempMax:Number = pathLength - 1;
				nextWayPoint = Math.round(Math.random() * tempMax);
				if (nextWayPoint == tempWayPoint) {
					if (nextWayPoint == tempMax) {
						nextWayPoint = 0;
					} else {
						nextWayPoint += 1;
					}
				}
			}
		}
		
		var angle:Number = Math.atan2(distY, distX);
		_root[myName]._x = _root[myName]._x + speed*Math.cos(angle);
		_root[myName]._y = _root[myName]._y + speed*Math.sin(angle);
	}
	
	private function turnMeAround2():Void {
		//find the distance between the desired angle of travel and current angle
		travelAngle = Math.atan2(distY, distX);
		travelAngle = Math.floor(travelAngle * (180/Math.PI));
		currentAngle = _root[myName]._rotation;
		distOfAngles = travelAngle - currentAngle;
		
		//choose the shortest turning direction
		if (distOfAngles > 180) {
			distOfAngles -= 360;
		} else if (distOfAngles < -180) {
			distOfAngles += 360;
		}
		
		//set the turn speed
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
	}
}