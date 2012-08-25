﻿// Darwin Games 2012package {	import flash.geom.*;	import flash.display.*;	import flash.events.*;	import flash.utils.*;	public class Game extends Sprite {		var mainTimeline;		var sportingEventList = ['dash', 'diving'];		var currentEventIndex = -1;		var sportingEvents = {			'dash' : {				'simulation' : Dash,				'name' : '500 Pixel Dash',				'rules' : 'Creature to reach the goal first or move the farthest wins.',				'width' : 500,				'height' : 150			},			'diving' : {				'simulation' : Diving,				'name' : 'Dead Cat Bounce',				'rules' : 'Highest bounce after initial impact wins.',				'width' : 200,				'height' : 500			}		};		var currentSportingEvent = 'diving';		var CONCURRENT_SIMS = 3;		var simulationBitmapDatas;		var simulations;		var spritesheetBitmapData;		var backbufferBitmapData;		var frontbufferBitmapData;		var frontbufferBitmap;		var stageRect;		var origo = new Point(0,0);		var betting = new Betting();		var frameCounter = 0;		var timePerCompo;		var gettingMoney = 0;		var gettingMoneySpeed;		function r(obj) {			return new Rectangle(0, 0, obj.width, obj.height);		}		var phase = 'BETTING';		var blinkCounter = 0;		function blinkYellow() {			blinkCounter++;			betting.yellow.visible = (blinkCounter % 10) < 5;		}		function compoFinishTransition() {			phase = 'COMPO_FINISHING';			(new WhistleSound()).play();			for (var j = 0; j < CONCURRENT_SIMS; j++) {				simulations[j].active = false;			}			setTimeout(compoFinished, 500);		}		var latestLosers = [];		var latestWinner;		function currentBestSim() {			var bestSim = 0;			var bestFitness = -10000000;			for (var i = 0; i < CONCURRENT_SIMS; i++) {				var fitness = simulations[i].fitness();				if (fitness > bestFitness) {					bestSim = i;					bestFitness = fitness;				}			}			// Don't mention winner if it's just the initial condition of diving			compoScreen.winning.visible = (bestFitness != -10000);			return bestSim;		}		function compoFinished() {			var bestSim = currentBestSim();			latestLosers = [];			latestWinner = bestSim;			for (var i = 0; i < CONCURRENT_SIMS; i++) {				if (i != bestSim) {					latestLosers.push(i);				}			}			// If bet on the winner, then triple money?			var amountBetOnWinner = int(betting['amount' + (bestSim + 1)].text);			gettingMoney = amountBetOnWinner * 3;			gettingMoneySpeed = Math.max(1, Math.round(gettingMoney / 60));			// Indicate which one was the winner			betting.yellow.x = betting['rect' + (bestSim + 1)].x;			removeChild(compoScreen);			addChild(betting);			introduceNewCreaturesSequence = 60;			startBetting();		}		var introduceNewCreaturesSequence = 0;		function refresh(evt) {			frameCounter++;			if (phase == 'SPORT') {				if (frameCounter < 90) {					if ((frameCounter % 30)==0) {						(new CountdownSound()).play();					}				}				if (frameCounter == 90) {					(new EventStartSound()).play();					for (var i = 0; i < CONCURRENT_SIMS; i++) {						var sim = simulations[i];						sim.start();					}				}				if (frameCounter > 90 && (frameCounter%60)==0) {					compoScreen.timer.text = int(compoScreen.timer.text) - 1;				}				// Indicate currently winning sim				var bestSim = currentBestSim();				var layout = simulations[0].layout(bestSim);				compoScreen.winning.x = layout.x;				compoScreen.winning.y = layout.y;				backbufferBitmapData.fillRect(r(backbufferBitmapData), 0);				for (i = 0; i < CONCURRENT_SIMS; i++) {					sim = simulations[i];					var simulationBitmapData = simulationBitmapDatas[i];					sim.tick();					sim.render();					backbufferBitmapData.copyPixels(simulationBitmapData, r(simulationBitmapData), sim.layout(i), null, new Point(0,0), true);					if (sim.isWinner()) {						compoFinishTransition();						return;					}				}				if (int(compoScreen.timer.text) == 0) {					compoFinishTransition();				}				frontbufferBitmapData.copyPixels(backbufferBitmapData, r(backbufferBitmapData), origo);			}			if (phase == 'BETTING') {				if (gettingMoney > 0) {					blinkYellow();					betting.coins.text = int(betting.coins.text) + gettingMoneySpeed;					gettingMoney -= gettingMoneySpeed;					if ((frameCounter%12)==0) (new CashSound()).play();				} else {					// Make loser creatures disappear and replace with new ones					if (introduceNewCreaturesSequence > 0) {						introduceNewCreaturesSequence--;						if (introduceNewCreaturesSequence == 30) {							var madeMutant = false; // make one mutant clone, other one just put random							for (i = 0; i < latestLosers.length; i++) {								var loserIndex = latestLosers[i];								betting.removeChild(creaturePreviewBitmaps[loserIndex]);								(new Explosion()).play();								if (madeMutant) {									creatures[loserIndex] = makeRandomCreature();								} else {									creatures[loserIndex] = creatures[latestWinner].makeMutant();									madeMutant = true;								}							}						}						if (introduceNewCreaturesSequence == 0) {							for (i = 0; i < latestLosers.length; i++) {								loserIndex = latestLosers[i];								showPreviewOfCreatureAtIndex(loserIndex);							}						}						if (introduceNewCreaturesSequence == 0) {							(new ThemeSong()).play()						}					}					betting.yellow.visible = false;				}			}		}		var creatures = [];		function makeSpecificCreature(sheetIndex) {			var creatureBitmapData = new BitmapData(32, 32);			creatureBitmapData.copyPixels(spritesheetBitmapData, new Rectangle(sheetIndex*32,32,32,32), new Point(0,0));			var creature = new Creature(creatureBitmapData);			return creature;		}		function makeRandomCreature() {			var randomSlot = Math.floor(Math.random() * 12);			return makeSpecificCreature(randomSlot);		}		function makeCreatures() {			creatures.push(makeSpecificCreature(1));			creatures.push(makeSpecificCreature(6));			creatures.push(makeSpecificCreature(7));		}		function startSport() {			frontbufferBitmapData.fillRect(r(frontbufferBitmapData), 0x00000000);			compoScreen.timer.text = timePerCompo;			phase = 'SPORT';			simulationBitmapDatas = [];			simulations = [];			for (var i = 0; i < CONCURRENT_SIMS; i++) {				var simulationBitmapData = new BitmapData(sportingEvents[currentSportingEvent]['width'], sportingEvents[currentSportingEvent]['height']);				var sim = new sportingEvents[currentSportingEvent]['simulation'](simulationBitmapData, spritesheetBitmapData, creatures[i]);				simulationBitmapDatas.push(simulationBitmapData);				simulations.push(sim);			}			frameCounter=0;		}		function playAgain(evt) {			mainTimeline.newGame();		}		var wentBrokeOl = null;		function wentBroke() {			(new WentBrokeSound()).play();			wentBrokeOl = new WentBrokeOverlay();			addChild(wentBrokeOl);			wentBrokeOl.playAgain.addEventListener(MouseEvent.CLICK, playAgain);			phase = 'BROKE';		}		public function startBetting() {			++currentEventIndex;			if (currentEventIndex >= sportingEventList.length) {				currentEventIndex = 0;			}			currentSportingEvent = sportingEventList[currentEventIndex];			phase = 'BETTING';			betting.amount1.text = 0;			betting.amount2.text = 0;			betting.amount3.text = 0;			betting.eventName.text = sportingEvents[currentSportingEvent].name;			betting.eventRules.text = sportingEvents[currentSportingEvent].rules;			if (int(betting.coins.text) == 0 && gettingMoney == 0) {				wentBroke();			}		}		function betIncrement() {			if (betting.ba1.selected) return 1;			if (betting.ba10.selected) return 10;			if (betting.ba100.selected) return 100;		}		function notEnoughCoins() {			(new ErrorSound()).play()		}		function cancelBets(evt) {			for (var i = 0; i < CONCURRENT_SIMS; i++) {				betting.coins.text = int(betting.coins.text) + int(betting['amount' + (i+1)].text);				betting['amount' + (i+1)].text = 0;			}		}		function placeBet(creatureIndex) {			if (int(betting.coins.text) < betIncrement()) {				notEnoughCoins();			} else {				betting['amount' + creatureIndex].text = int(betting['amount' + creatureIndex].text) + betIncrement();				betting.coins.text = int(betting.coins.text) - betIncrement();				(new SelectSound()).play();			}		}		public function placeBet1(evt) {			placeBet(1);		}		public function placeBet2(evt) {			placeBet(2);		}		public function placeBet3(evt) {			placeBet(3);		}		var creaturePreviewBitmaps = [];		public function showPreviewOfCreatureAtIndex(i) {			var creaturePreviewBitmap = new Bitmap(creatures[i].bitmapdata);			creaturePreviewBitmap.x = betting['rect' + (i+1)].x - betting['rect' + (i+1)].width/2;			creaturePreviewBitmap.y = betting['rect' + (i+1)].y - betting['rect' + (i+1)].height/2;			creaturePreviewBitmap.scaleX = 8;			creaturePreviewBitmap.scaleY = 8;			betting.addChild(creaturePreviewBitmap);			if (creaturePreviewBitmaps.length != 0) {				creaturePreviewBitmaps[i] = creaturePreviewBitmap;			} else {				creaturePreviewBitmaps.push(creaturePreviewBitmap);							}		}		public function initBettingScreen() {			betting.start.addEventListener(MouseEvent.CLICK, matchStartClicked);			betting.bet1.addEventListener(MouseEvent.CLICK, placeBet1);			betting.bet2.addEventListener(MouseEvent.CLICK, placeBet2);			betting.bet3.addEventListener(MouseEvent.CLICK, placeBet3);			betting.cancelBets.addEventListener(MouseEvent.CLICK, cancelBets);			for (var i = 0; i < CONCURRENT_SIMS; i++) {				showPreviewOfCreatureAtIndex(i);			}		}		var compoScreen;		public function matchStartClicked(evt) {			// Could transition here			removeChild(betting);			addChild(compoScreen);			startSport();		}		function initCompoScreen(mainTimeline) {			compoScreen = new CompoScreen();			backbufferBitmapData = new BitmapData(mainTimeline.stage.stageWidth, mainTimeline.stage.stageHeight);			backbufferBitmapData.fillRect(r(backbufferBitmapData), 0x0);			frontbufferBitmapData = backbufferBitmapData.clone();			frontbufferBitmap = new Bitmap(frontbufferBitmapData);			compoScreen.addChild(frontbufferBitmap);			timePerCompo = int(compoScreen.timer.text);		}		public function Game(mainTimeline) {			this.mainTimeline = mainTimeline;			mainTimeline.addEventListener(Event.ENTER_FRAME, refresh);			spritesheetBitmapData = new Sheet(0,0);			makeCreatures();			initCompoScreen(mainTimeline);			initBettingScreen();			addChild(betting);			startBetting();//			startSport();		}	}}