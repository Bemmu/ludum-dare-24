// Darwin Games 2012
package {
	import flash.geom.*;
	import flash.display.*;
	import flash.events.*;

	public class Game extends Sprite {
		var CONCURRENT_SIMS = 3;
		var simulationBitmapDatas;
		var simulations;

		var backbufferBitmapData;
		var frontbufferBitmapData;
		var frontbufferBitmap;
		var stageRect;
		var origo = new Point(0,0);

		function r(obj) {
			return new Rectangle(0, 0, obj.width, obj.height);
		}

		function refresh(evt) {
			sim.tick();

			sim.render();

			backbufferBitmapData.copyPixels(simulationBitmapData, r(simulationBitmapData), new Point(150, 100));

			frontbufferBitmapData.copyPixels(backbufferBitmapData, r(backbufferBitmapData), origo);
		}

		public function Game(mainTimeline) {

			creatures = [];

			for (var i = 0; i < CONCURRENT_SIMS; i++) {
				var simulationBitmapData = new BitmapData(500, 100);
				simulationBitmapDatas.push(simulationBitmapData);
				var sim = new Simulation(simulationBitmapData);
			}


			backbufferBitmapData = new BitmapData(mainTimeline.stage.stageWidth, mainTimeline.stage.stageHeight);

			frontbufferBitmapData = backbufferBitmapData.clone();
			frontbufferBitmap = new Bitmap(frontbufferBitmapData);
			mainTimeline.addEventListener(Event.ENTER_FRAME, refresh);
			addChild(frontbufferBitmap);
		}
	}
}