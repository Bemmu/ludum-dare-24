package {
	import flash.display.*;
	import flash.geom.*;

	public class Creature {
		var bitmapdata;
		var amplitudes;
		var frequencies;
		var phases;

		var BLACK = 0xff000000;
		var BLUE = 0xff0000ff;

		public var madeFromSpriteSheetSlot = null;

		public function Creature(bitmapdata:BitmapData, amplitudes = null, frequencies = null, phases = null) {
			this.bitmapdata = bitmapdata.clone();

			if (amplitudes) this.amplitudes = amplitudes.slice(0);
			if (frequencies) this.frequencies = frequencies.slice(0);
			if (phases) this.phases = phases.slice(0);

			this.amplitudes = [];
			this.frequencies = [];
			this.phases = [];

			for (var i = 0; i < 100; i++) {
				this.amplitudes.push(Math.random() * Math.random() * 30);
				this.frequencies.push(Math.random() * 0.1);
				this.phases.push(Math.random() * Math.PI * 2);
			}
		}

		function isConnected(bmp) {
			var bmp = bmp.clone(); // make working copy so we can mark pixels

			// Start exploring from the first nontransparent pixel
			var fx = null, fy = null;
			for (var y = 0; y < bmp.height; y++) {
				for (var x = 0; x < bmp.width; x++) {
					var color = bmp.getPixel32(x, y) && 0xff000000;
					if (color > 0) {
						fx = x; 
						fy = y;
						break;
					}
				}
				if (fx != null) break;
			}

			// Pure transparent, let's say that isn't connected?
			if (fx == null) {
				return false;
			}

			var todo = [{'x':fx, 'y':fy}];
			var directions;

			while (todo.length > 0) {
				var item = todo.pop();
//				trace(todo.length + ' items left');
				bmp.setPixel32(item['x'], item['y'], 0);

				fx = item['x']; fy = item['y'];
				directions = [[fx-1,fy],[fx+1,fy],[fx,fy+1],[fx,fy-1],[fx-1,fy-1],[fx+1,fy+1],[fx-1,fy+1],[fx+1,fy-1]];
				for (var j = 0; j < directions.length; j++) {
					// Already on todo list?
					var entry = {'x':directions[j][0],'y':directions[j][1]};
					var already = false;
					for (var k = 0; k < todo.length; k++) {
						if (todo[k]['x'] == entry['x'] && todo[k]['y'] == entry['y']) {
							already = true;
						}
					}
					if (already) continue;

					if ((bmp.getPixel32(entry['x'], entry['y']) && 0xff000000) > 0) {
//						trace('Explore to ' + entry['x'] + ', ' + entry['y']);
						todo.push(entry);
					}
				}
			}

			// Now if there are any nonzero pixels left then not connected
			for (y = 0; y < bmp.height; y++) {
				for (x = 0; x < bmp.height; x++) {
					if ((bmp.getPixel32(x, y) && 0xff000000) > 0) {
						return false;
					}
				}
			}

			return true;
		}

		function identicalBitmaps(a, b) {
			for (var y = 3; y < 29; y++) {
				for (var x = 3; x < 29; x++) {
					if (a.getPixel32(x,y) == BLACK && b.getPixel32(x,y) != BLACK) return false;
					if (a.getPixel32(x,y) == BLUE && b.getPixel32(x,y) != BLUE) return false;
				}
			}
			return true;
		}

		function mutate(bmp) {
/*			var xPos = 2 + int(Math.random() * (32 - 4));
			var yPos = 2 + int(Math.random() * (32 - 4));
			var width = int(Math.random() * (32 - xPos));
			var height = int(Math.random() * (32 - yPos));
*/
			var mutant = bmp.clone();
			var rate = 0.95;

			// Extend random corner points
			var madeChange = false;
			while (!madeChange) {
				for (var y = 2; y < 31; y++) {
					for (var x = 2; x < 28; x++) {
						if (!(bmp.getPixel32(x,y) && 0xff000000)) continue;

						if (Math.random() < rate) continue;

						var edible = 
							((bmp.getPixel32(x-1,y+1) && 0xff000000) || (bmp.getPixel32(x,y+1) && 0xff000000) || (bmp.getPixel32(x+1,y+1) && 0xff000000)) ||
							((bmp.getPixel32(x-1,y+1) && 0xff000000) || (bmp.getPixel32(x-1,y) && 0xff000000) || (bmp.getPixel32(x-1,y-1) && 0xff000000)) ||
							((bmp.getPixel32(x-1,y-1) && 0xff000000) || (bmp.getPixel32(x,y-1) && 0xff000000) || (bmp.getPixel32(x+1,y-1) && 0xff000000)) ||
							((bmp.getPixel32(x+1,y+1) && 0xff000000) || (bmp.getPixel32(x+1,y) && 0xff000000) || (bmp.getPixel32(x+1,y-1) && 0xff000000));

						// Randomly eat some flesh, but only if after doing that connections still remain.
						if (edible && Math.random() < 0.5) {
							mutant.setPixel32(x,y,0x00000000);
						} else {
							if (!(bmp.getPixel32(x+1,y) && 0xff000000)) { 
								madeChange = true;
								mutant.setPixel32(x+1,y,0xff000000);
							}
							if (!(bmp.getPixel32(x-1,y) && 0xff000000)) { 
								madeChange = true;
								mutant.setPixel32(x-1,y,0xff000000);
							}
							if (!(bmp.getPixel32(x,y+1) && 0xff000000)) { 
								madeChange = true;
								mutant.setPixel32(x,y+1,0xff000000);
							}
							if (!(bmp.getPixel32(x,y-1) && 0xff000000)) { 
								madeChange = true;
								mutant.setPixel32(x,y-1,0xff000000);
							}
						}

/*						if (bmp.getPixel32(x,y) == BLACK && bmp.getPixel32(x-1,y) != BLACK) {
							madeChange = true;
							bmp.setPixel(x-1,y,0xffffff00);
						}
						if (bmp.getPixel32(x,y) == BLACK && bmp.getPixel32(x,y+1) != BLACK) {
							bmp.setPixel(x,y+1,0xffffff00);
							madeChange = true;
						}
						if (bmp.getPixel32(x,y) == BLACK && bmp.getPixel32(x,y-1) != BLACK) {
							madeChange = true;
							bmp.setPixel(x,y-1,0xffffff00);
						}*/
					}
				}
			}

			bmp.copyPixels(mutant, new Rectangle(0, 0, mutant.width, mutant.height), new Point(0,0 ));

/*			var failsafeCounter = 50;
			var cont = true;
			while (cont) {
				failsafeCounter--;
				if (failsafeCounter == 0) {
					trace('failsafe triggered');
					break;
				}

				var before = bmp.clone();
				bmp.copyPixels(
					bmp,
					new Rectangle(xPos, yPos, width, height),
					new Point(int(Math.random() * 32), int(Math.random() * 32)),
					null, new Point(0,0), true						
				);
//				bmp.fillRect(new Rectangle(0, 0, 32, 32), 0xffffff00);
				cont = identicalBitmaps(bmp, before);
			}*/
		}

		public function makeMutant() {

/*			// Should also see that it really changed

			// Copy random areas around but don't allow disconnection
			var cont = true;
			var disconnected = true;
//			disconnected = !isConnected(bmp);

//			return new Creature(bmp, amplitudes, frequencies, phases);

			var bmp;
			var maxLoops = 5;
			while (disconnected) {
				bmp = bitmapdata.clone();
				while (cont) {
					var xPos = int(Math.random() * 32);
					var yPos = int(Math.random() * 32);
					var width = int(Math.random() * (32 - xPos));
					var height = int(Math.random() * (32 - yPos));

					var before = bmp.clone();
					bmp.copyPixels(
						bmp,
						new Rectangle(xPos, yPos, width, height),
						new Point(int(Math.random() * 32), int(Math.random() * 32)),
						null, new Point(0,0), true						
					);
					if (identicalBitmaps(bmp, before)) {
						trace('Doing again as change had no effect');
						cont = true;	
					} else {
						cont = false;//Math.random() < 0.5;
					}
				}
				maxLoops--;
				if (maxLoops == 0) {
					trace('Giving up trying to find a connected mutant');
					break;
				}
				disconnected = !isConnected(bmp);
			}
*/
			var mutatedBmp = bitmapdata.clone();
			mutate(mutatedBmp);
			return new Creature(mutatedBmp/*, amplitudes, frequencies, phases*/);
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
