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

			this.amplitudes = [];
			this.frequencies = [];
			this.phases = [];

			for (var i = 0; i < 100; i++) {
				this.amplitudes.push(Math.random() * Math.random() * 50);
				this.frequencies.push(Math.random() * 0.3);
				this.phases.push(Math.random() * Math.PI * 2);
			}
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
