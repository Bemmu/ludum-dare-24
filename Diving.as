package {
	import flash.display.*;
	import flash.geom.*;

	public class Diving extends Simulation {
		public function Diving(buffer:BitmapData, spritesheetBitmapData:BitmapData, creature:Creature) {
			super(buffer, spritesheetBitmapData, creature);
		}

		override public function configureCompoScreen(compoScreen) {
		}

		override public function setPrefs() {
			this.musclesEnabled = true;
			this.gravity = 1;
			this.bounciness = 1.2;
			this.uniformMass = true;
			this.doBlueConnections = false;
			this.SPRING_BREAK_THRESHOLD = 0.875;
		}

		// Not known until timeout
		override public function isWinner() {
			return false;
		}

		var minY = 10000;
		override public function fitness() {
			var i, vertex;
			if (hasTouchedGround) {
				for (i = 0; i < vertices.length; i++) {
					if (vertices[i]['y'] < minY) {
						minY = vertices[i]['y'];
					}

//					minY = Math.min(vertices[i]['y'], minY);
				}
			}
			return -minY;

/*			var i, spring;
			var intactCount = 0;
			for (i = 0; i < springs.length; i++) {
				spring = springs[i];
				if (!spring['broken']) {
					intactCount++;
				}
			}
			var brokenness = intactCount / springs.length;
			return 1 - brokenness;*/
		}

		// How to put simulations of this kind next to each other
		override public function layout(i) {
			return new Point(150 + i * 200, 101 + 15)
		}
	}
}