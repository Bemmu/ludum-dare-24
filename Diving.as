package {
	import flash.display.*;
	import flash.geom.*;

	public class Diving extends Simulation {
		public function Diving(buffer:BitmapData, spritesheetBitmapData:BitmapData, creature:Creature) {
			super(buffer, spritesheetBitmapData, creature);
			this.musclesEnabled = false;
			this.gravity = 1;
			this.bounciness = 1;
		}

		// How to put simulations of this kind next to each other
		override public function layout(i) {
			return new Point(150 + i * 200, 100)
		}
	}
}