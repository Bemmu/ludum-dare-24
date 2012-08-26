package {
	import flash.display.*;
	import flash.geom.*;
	import flash.filters.*;

	public class Swim extends Simulation {
		var waterFilter;
		var waterBmp;

		public function Swim(buffer:BitmapData, spritesheetBitmapData:BitmapData, creature:Creature) {
			var waveHeight = 20;
			waterBmp = new BitmapData(buffer.width, buffer.height);
			for (var y = 0; y < waterBmp.height; y++) {
				for (var x = 0; x < waterBmp.width; x++) {
					var red = 0;
					var green = ((Math.sin(x*0.1)+1)/2)*waveHeight;
					waterBmp.setPixel32(x, y, 0xff000000 + ((red&0xff)<<16) + ((green&0xff)<<8));
				}
			}

			super(buffer, spritesheetBitmapData, creature);
		}

		// How to put simulations of this kind next to each other
		override public function layout(i) {
			return new Point(150 + 66 - 70, 110 + i * 150)
		}

		override public function setPrefs() {
			xPush = 1.2;
			yPush = -0.7;
			yOffset = 5;
			FRICTION = 0.1;
		}

		override public function applyGravity() {
			for (var i = 0; i < vertices.length; i++) {
				var vertex = vertices[i];
				var aboveWater = vertex['y'] < buffer.height/2;
				if (aboveWater) {
					vertex['y'] += gravity * vertex['mass']; // hey it's what people used to believe!
				} else {
					vertex['y'] -= gravity * vertex['mass']; // hey it's what people used to believe!
				}
			}
		}

		override public function configureCompoScreen(compoScreen) {
		}

		override public function renderBackground() {
			buffer.fillRect(new Rectangle(0, 0, buffer.width, buffer.height / 2), 0xff45618D);
			buffer.fillRect(new Rectangle(0, buffer.height / 2, buffer.width, buffer.height / 2), 0xff2521AD);
			waterFilter = new DisplacementMapFilter(waterBmp, new Point(Math.sin(tickCounter*0.1)*20,0), 1, 2, 50, 50, 'clamp');
			buffer.applyFilter(buffer, new Rectangle(0, 0, buffer.width, buffer.height), new Point(0, 0), waterFilter);
			waterFilter = null;
		}
	}
}