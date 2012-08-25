package {
	import flash.display.*;
	import flash.geom.*;

	public class Dash extends Simulation {
		public function Dash(buffer:BitmapData, spritesheetBitmapData:BitmapData, creature:Creature) {
			super(buffer, spritesheetBitmapData, creature);
		}

		// How to put simulations of this kind next to each other
		override public function layout(i) {
			return new Point(150, 100 + i * 150)
		}
	}
}