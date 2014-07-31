/*
	Garden of Bees
	Game Core
    
	Author:         Stephen R. Owens - www.studio-owens.com
	Copyright:      Copyright (c) 2014 Stephen R. Owens
	Last Update:    2009-01-09 22:22
	Created:        2008-08-09
*/

class Game {
	private var score:Number = 0;
	private var myName:String;
	private var touchedWalls:Number = 0;
	private var levelTitle:String;
	private var theR:Number = 0; //number of right clicks
	
//Constructor
	public function Game(s:Number, mName:String) {
		score = s;
		myName = mName;
	}
	
// Public Methods
	public function addScore(as:Number):Void {
		if (as > 0) {
			score += as;
		} else {
			score = 0;
		}
	}
	
	public function addR(r:Number):Void {
		theR += 1;
	}
	
	public function getR():Number {
		return theR;
	}
	
	public function getScore():Number {
		return score;
	}
	
	public function levelSetup():Void {
		_root["fairy1"].fairy.findStart();
		_root["magicClean"].magicFlower.levelChangeCleanUp();
		//make sure hero die spirit is off
		_root["heroSpirit"].gotoAndStop("END explode");
		removeMovieClip(_root["myMask"]);
		setupMist();
		setupSound();
		setupBlades(_root["blade"],48);
	}

// Private Methods
	private function setupSound():Void {
		// sound fx
		_root.soundHeroDie = new Sound();
        _root.soundHeroDie.attachSound("teleport");
		_root.soundExit = new Sound();
		_root.soundExit.attachSound("exit");
		_root.soundPickup = new Sound();
		_root.soundPickup.attachSound("pickmeup");
		_root.soundMagic = new Sound();
		_root.soundMagic.attachSound("magic");
		_root.soundMagicBomb = new Sound();
		_root.soundMagicBomb.attachSound("bomb");
		_root.soundMagicCoin = new Sound();
		_root.soundMagicCoin.attachSound("coin");
		_root.soundMagicPortal = new Sound();
		_root.soundMagicPortal.attachSound("portal");
		_root.soundMagicShield = new Sound();
		_root.soundMagicShield.attachSound("shield");
		_root.soundMagicShrink = new Sound();
		_root.soundMagicShrink.attachSound("shrink");
		//_root.soundMagicTimedshield = new Sound();
		//_root.soundMagicTimedshield.attachSound("timedshield");
		_root.soundMagicVinecurl = new Sound();
		_root.soundMagicVinecurl.attachSound("vinecurl");
		_root.soundMagicWind = new Sound();
		_root.soundMagicWind.attachSound("wind");
	}
	
	private function setupMist():Void {
		duplicateMovieClip (_root["walls"], "myMask", 2);
		_root["mist"].setMask(_root["myMask"]);
	}
	
	private function setupBlades(mcBlade:MovieClip, totalBlades:Number):Void {
		var method:Number = 3; // which method to use to place grass
		for (var i=1; i<=totalBlades; i++) {
			removeMovieClip(_root["mist"]["blade_"+i]);
			_root["mist"].attachMovie("bladeStill","blade_"+i, _root["mist"].getNextHighestDepth());
			//duplicateMovieClip(mcBlade, "blade_"+i, i);
			// set height between 15 and 80
			_root["mist"]["blade_"+i]._height = random(65)+15;
			// set width between 10 and 25
			_root["mist"]["blade_"+i]._width = random(15)+10;
			var rndPosX:Number = random(Stage.width);
			var rndPosY:Number = random(Stage.height);
			
			switch(method) {
			case 1:
				if (
					(rndPosX < Stage.width/8) 
					|| (rndPosX > (Stage.width-(Stage.width/8)))
					|| (rndPosY < (Stage.height/6)+16)
					|| (rndPosY > (Stage.height-(Stage.height/6)))
				) {
						_root["mist"]["blade_"+i]._x = bladePosAdjust(rndPosX, 'x');
						_root["mist"]["blade_"+i]._y = bladePosAdjust(rndPosY, 'x');
				}  else {
					switch (random(4)) { 
					case (0) : 
						_root["mist"]["blade_"+i]._x = bladePosAdjust(random(Stage.width/8), 'x'); 
						_root["mist"]["blade_"+i]._y = bladePosAdjust(random(Stage.height/6)+16, 'y');
						break; 
					case (1) : 
						_root["mist"]["blade_"+i]._x = bladePosAdjust(Stage.width - (random(Stage.width/8)), 'x'); 
						_root["mist"]["blade_"+i]._y = bladePosAdjust(random(Stage.height/6)+16, 'y'); 
						break; 
					case (2) : 
						_root["mist"]["blade_"+i]._x = bladePosAdjust(random(Stage.width/8), 'x'); 
						_root["mist"]["blade_"+i]._y = bladePosAdjust(Stage.height - (random(Stage.height/6)), 'y'); 
						break; 
					default : 
						_root["mist"]["blade_"+i]._x = bladePosAdjust(Stage.width - (random(Stage.width/8)), 'x'); 
						_root["mist"]["blade_"+i]._y = bladePosAdjust(Stage.height - (random(Stage.height/6)), 'y'); 
					}
				}
				break;
			case 2:
			//position grass blades anywhere
				_root["mist"]["blade_"+i]._x = random(Stage.width);
				_root["mist"]["blade_"+i]._y = random(Stage.height);
				break;
			case 3:
			//position just around the border not random but in a pseudo random fashon
				_root["mist"]["blade_"+i]._x = bladePseudoPos(i, totalBlades, 'x');
				_root["mist"]["blade_"+i]._y = bladePseudoPos(i, totalBlades, 'y');
				break;
			case 4:
			//stright up box border for grass placement
				_root["mist"]["blade_"+i]._x = bladeBorderPos(i, totalBlades, 'x');
				_root["mist"]["blade_"+i]._y = bladeBorderPos(i, totalBlades, 'y');
				break;
			}
			
			// start at a random point in the sway sequence
			_root["mist"]["blade_"+i].gotoAndPlay(random(40));
		}
	}
	
	private function bladeBorderPos(n:Number, tot:Number, dir:String):Number {
		var modPos:Number = 0;
		//clockwise rotation placement goes top, right, bottom, left
		switch (dir) {
		case 'x':
			if (n < tot/4) {
				modPos = n * (Stage.width/(tot/4));
			} else if (n < (tot/4) * 2){
				modPos = Stage.width - 20;
			} else if (n < (tot/4) * 3){
				modPos = (n-((tot/4)*2)) * (Stage.width/(tot/4));
			} else {
				modPos = 6;
			}
			break;
		case 'y':
			if (n < tot/4) {
				modPos = 64;
			} else if (n < (tot/4) * 2){
				modPos = (n-(tot/4)) * (Stage.height/(tot/4));
			} else if (n < (tot/4) * 3){
				modPos = Stage.height;
			} else {
				modPos = (n-(tot/4)*3) * (Stage.height/(tot/4));
			}
			break;
		}
		return modPos;
	}
	
	private function bladePseudoPos(n:Number, tot:Number, dir:String):Number {
		var modPos:Number = 0;
		//clockwise rotation placement goes in rows staring with top, the the right side, then bottom, and ends with the left side
		switch (dir) {
		case 'x':
			if (n < tot/4) {
				modPos = (n * (Stage.width/(tot/4)))+random(20);
			} else if (n < (tot/4) * 2){
				modPos = (Stage.width - 20)-random(20);
			} else if (n < (tot/4) * 3){
				modPos = ((n-((tot/4)*2)) * (Stage.width/(tot/4)))+random(20);
			} else {
				modPos = 6+random(20);
			}
			break;
		case 'y':
			if (n < tot/4) {
				modPos = (64)+random(20);
			} else if (n < (tot/4) * 2){
				modPos = ((n-(tot/4)) * (Stage.height/(tot/4)))+random(20);
			} else if (n < (tot/4) * 3){
				modPos = Stage.height-random(20);
			} else {
				modPos = ((n-(tot/4)*3) * (Stage.height/(tot/4)))+random(20);
			}
			break;
		}
		return modPos;
	}
	
	private function bladePosAdjust(pos:Number, dir:String):Number {
		//modify the postion of the grass around the edges so that it is more on screen than off
		var modPos:Number = 0;
		switch(dir) {
		case('x'):
			if (pos <= 12) {
				modPos = pos + random(200)+12;
			} else if (pos >= Stage.width - 12){
				modPos = pos - random(200)+12;
			} else {
				modPos = pos;
			}
			break;
		case('y'):
			if (pos < ((Stage.height/6)+16)) {
				modPos = pos+64;
			} else {
				modPos = pos-random(150);
			}
			break;
		}
		return modPos;
	}
}
