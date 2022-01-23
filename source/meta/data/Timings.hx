package meta.data;

import gameObjects.userInterface.notes.*;
import meta.state.PlayState;

/**
	Here's a class that calculates timings and judgements for the songs and such
**/
class Timings
{
	//
	public static var accuracy:Float;
	public static var trueAccuracy:Float;
	public static var judgementRates:Array<Float>;

	// from left to right
	// max milliseconds, score from it and percentage
	public static var judgementsMap:Map<String, Array<Dynamic>> = [
		"sick" => [0, 55, 350, 100, ' [SFC]'],
		"good" => [1, 80, 150, 75, ' [GFC]'],
		"bad" => [2, 100, 0, 25, ' [FC]'],
		"shit" => [3, 120, -50, -150],
		"miss" => [4, 140, -100, -175],
	];

	public static var msThreshold:Float = 0;

	// set the score judgements for later use
	public static var scoreRating:Map<String, Int> = [
		"S+" => 100,
		"S" => 95,
		"A" => 90,
		"b" => 85,
		"c" => 80,
		"d" => 75,
		"e" => 70,
		"f" => 65,
	];

	public static var ratingFinal:String = "f";
	public static var notesHit:Int = 0;
	public static var segmentsHit:Int = 0;
	public static var comboDisplay:String = '';

	public static var gottenJudgements:Map<String, Int> = [];
	public static var smallestRating:String;

	public static function callAccuracy()
	{
		// reset the accuracy to 0%
		accuracy = 0.001;
		trueAccuracy = 0;
		judgementRates = new Array<Float>();

		// reset ms threshold
		var biggestThreshold:Float = 0;
		for (i in judgementsMap.keys())
			if (judgementsMap.get(i)[1] > biggestThreshold)
				biggestThreshold = judgementsMap.get(i)[1];
		msThreshold = biggestThreshold;

		// set the gotten judgement amounts
		for (judgement in judgementsMap.keys())
			gottenJudgements.set(judgement, 0);
		smallestRating = 'sick';

		notesHit = 0;
		segmentsHit = 0;

		ratingFinal = "f";

		comboDisplay = '';
	}

	/*
		You can create custom judgements here! just assign values to it as explained below.
		Null means that it is the highest judgement, meaning it doesn't get a check and is set automatically
	 */
	public static function accuracyMaxCalculation(realNotes:Array<Note>)
	{
		// first we split the notes and get a total note number
		var totalNotes:Int = 0;
		for (i in 0...realNotes.length)
		{
			if (realNotes[i].mustPress)
				totalNotes++;
		}
	}

	public static function updateAccuracy(judgement:Int, ?isSustain:Bool = false, ?segmentCount:Int = 1)
	{
		if (!isSustain)
		{
			notesHit++;
			accuracy += (Math.max(0, judgement));
		}
		else
		{
			accuracy += (Math.max(0, judgement) / segmentCount);
		}
		trueAccuracy = (accuracy / notesHit);

		updateFCDisplay();
		updateScoreRating();
	}

	public static function updateFCDisplay()
	{
		// update combo display
		comboDisplay = '';
		if (judgementsMap.get(smallestRating)[4] != null)
			comboDisplay = judgementsMap.get(smallestRating)[4];

		// this updates the most so uh
		PlayState.uiHUD.updateScoreText();
	}

	public static function getAccuracy()
	{
		return trueAccuracy;
	}

	public static function updateScoreRating()
	{
		var biggest:Int = 0;
		for (score in scoreRating.keys())
		{
			if (scoreRating.get(score) <= trueAccuracy && scoreRating.get(score) >= biggest)
			{
				biggest = scoreRating.get(score);
				ratingFinal = score;
			}
		}
	}

	public static function returnScoreRating()
	{
		return ratingFinal;
	}
}
