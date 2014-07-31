/*
	Garden of Bees
	Trigger Events by the Hero
    
	Author:         Stephen R. Owens - www.studio-owens.com
	Copyright:      Copyright (c) 2014 Stephen R. Owens
	Last Update:    2008-09-07 07:52
	Created:        2008-08-09
*/

class Trigger extends Collectable {
	private var myValue:Number = 0;
	private var myTarget:String;
	private var targetFrame:String; //this is the frame name of the target object goto when triggered
	private var myName:String;
	
// Constructor
	public function Trigger(mValue:Number, mTarget:String, mName:String) {
		myValue = mValue;
		myTarget = mTarget;
		targetFrame = "triggerAction";
		myName = mName;
		//_root[myTarget].gotoAndStop("idle");
	}
	
// Public Methods
	private function setTragetFrame(tfName:String):Void {
		targetFrame = tfName;
	}
	
// Private Methods
	private function pickMeUp():Void {
		_root[myTarget].gotoAndPlay(targetFrame);
		setProperty(_root[myName], _x, -100);
		setProperty(_root[myName], _y, -100);
		_root.score += myValue; // add to score
	}
}
