package {
	import flash.display.*;
	import flash.geom.*;

	public class Creature {
		var bitmapdata;
		var amplitudes;
		var frequencies;
		var phases;

		public function Creature(bitmapdata:BitmapData) {
			this.bitmapdata = bitmapdata.clone();
//			this.amplitudes = [30,30,30];
//			this.frequencies = [0.1,0.1,0.1];
			this.amplitudes = [0,0,0,0,0,30];
			this.frequencies = [0,0,0,0,0,0.1];
		}

		public function getAmplitude(i) {
			if (!amplitudes || i >= amplitudes.length) return 0;
			return amplitudes[i];
		}

		public function getFrequency(i) {
			if (!frequencies || i >= frequencies.length) return 0;
			return frequencies[i];
		}

		public function getPhase(i) {
			if (!phases || i >= phases.length) return 0;
			return phases[i];
		}
	}
}
