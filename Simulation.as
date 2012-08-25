package {
	import flash.display.*;
	import flash.geom.*;

	public class Simulation {
		var vertices;
		var bounds;
		var springs;
		var gravity = 0.25;
		var buffer;
		var spritesheetBitmapData;
		var tickCounter = 0;
		var bounciness = 0;

		// Different types of vertices like head, foot, hand just to make it look more human.

		public function Simulation(buffer:BitmapData, spritesheetBitmapData:BitmapData, creature:Creature) {
			this.buffer = buffer;
			this.spritesheetBitmapData = spritesheetBitmapData;

			vertices = [];
			springs = [];

			var map_xy_to_vertex = {};

			var creatureBitmapData = creature.bitmapdata;
			var nextNeededCreatureValue = 0;

			var BLACK = 0xff000000;
			var BLUE = 0xff0000ff;

			for (var y = 0; y < 32; y++) {
				for (var x = 0; x < 32; x++) {
					var p = creatureBitmapData.getPixel32(x, y);

					if (p == BLACK || p == BLUE) {
						var mass = p == BLACK ? 0.05 : 1;

						var index = vertices.length;
						var mapStr = x + '_' + y;
						map_xy_to_vertex[mapStr] = index;

						vertices.push(
							{'x' : x, 'y' : y, 'sprite' : 0, 'mass' : mass}
						);
					}
				}
			}

			// Make springs between all touching pixels
			for (y = 0; y < 32; y++) {
				for (x = 0; x < 32; x++) {
					p = creatureBitmapData.getPixel32(x, y);
					if (p != BLACK && p != BLUE) continue;

					var connections = [[x-1,y+1],[x,y+1],[x+1,y+1],[x+1,y]];

					for (var j = 0; j < connections.length; j++) {
						var c = connections[j];
						var pixel = creatureBitmapData.getPixel32(c[0], c[1]);
						if (pixel == BLACK || pixel == BLUE) {
							var a = map_xy_to_vertex[x + '_' + y];
							var b = map_xy_to_vertex[c[0] + '_' + c[1]];
							springs.push({'a' : a, 'b' : b, 'elasticity' : 0.2});
						}
					}
				}
			}

			// Additionally every blue pixel should be rigidly connected to every other blue pixel
			var bluePixels = [];
			for (y = 0; y < 32; y++) {
				for (x = 0; x < 32; x++) {
					p = creatureBitmapData.getPixel32(x, y);
					if (p == BLUE) {
						bluePixels.push(x + '_' + y);
					}
				}
			}	

			for (var l = 0; l < bluePixels.length; l++) {
				for (var m = 0; m < l; m++) {
					springs.push({
						'a' : map_xy_to_vertex[bluePixels[l]],
						'b' : map_xy_to_vertex[bluePixels[m]],
						'elasticity' : 1,
						'amplitude' : creature.getAmplitude(nextNeededCreatureValue), 
						'frequency' : creature.getFrequency(nextNeededCreatureValue), 
						'phase' : creature.getPhase(nextNeededCreatureValue)
					});

					nextNeededCreatureValue++;
				}
			}		

			var vertexScale = 3.5;
			for (var k = 0; k < vertices.length; k++) {
				vertices[k]['x'] *= vertexScale;
				vertices[k]['y'] *= vertexScale;
			} 

			var i, vertex, spring, joint;

			var xPush = 0, yPush = 0;

			// No energy in the system at first
			for (i = 0; i < vertices.length; i++) {
				vertex = vertices[i];
				vertex['prevX'] = vertex['x'] - xPush * Math.random();
				vertex['prevY'] = vertex['y'] - yPush * Math.random();
			}

			// Be satisfied by initial distances for springs
			for (i = 0; i < springs.length; i++) {
				spring = springs[i];
				var ax = vertices[spring['a']]['x'];
				var ay = vertices[spring['a']]['y'];
				var bx = vertices[spring['b']]['x'];
				var by = vertices[spring['b']]['y'];
				spring['desiredDistance'] = Math.sqrt((ax-bx)*(ax-bx) + (ay-by)*(ay-by));
			}
		}
		public function tick() {
			var i, vertex, ax, ay, bx, by;
			tickCounter++;

			// Apply gravity
			for (i = 0; i < vertices.length; i++) {
				vertex = vertices[i];
				vertex['y'] += gravity * vertex['mass'];
			}

			// Springs
			for (i = 0; i < springs.length; i++) {
				var spring = springs[i];
				ax = vertices[spring['a']]['x'];
				ay = vertices[spring['a']]['y'];
				bx = vertices[spring['b']]['x'];
				by = vertices[spring['b']]['y'];
				var desiredDistance = spring['desiredDistance'];

				if (spring['amplitude']) {
					var waviness = Math.sin(spring['frequency'] * tickCounter + spring['phase']) * spring['amplitude'];
					desiredDistance += waviness;
				}

				var midx = (ax+bx)/2;
				var midy = (ay+by)/2;
				ax -= midx; ay -= midy;
				bx -= midx; by -= midy;

				// Make distance (approach) the desired one
				var dist = Math.sqrt((ax-bx)*(ax-bx) + (ay-by)*(ay-by));
				var elasticity = 1;
				if (spring['elasticity'] != undefined) {
					elasticity = spring['elasticity'];
				}

				var coeff = 1 * (1-elasticity) + (desiredDistance / dist) * elasticity;
				ax *= coeff; ay *= coeff;
				bx *= coeff; by *= coeff;

				// Rewind operations
				ax += midx; ay += midy;
				bx += midx; by += midy;

				vertices[spring['a']]['x'] = ax;
				vertices[spring['a']]['y'] = ay;
				vertices[spring['b']]['x'] = bx;
				vertices[spring['b']]['y'] = by;
			}			

			// Bounds checking
			for (i = 0; i < vertices.length; i++) {
				vertex = vertices[i];
				if (vertex['y'] >= buffer.height) {
					vertex['y'] = (1-bounciness) * buffer.height + bounciness * (buffer.height - (vertex['y'] - vertex['prevY']));
				}
				if (vertex['y'] < 0) {
					vertex['y'] = 0;
				}
				if (vertex['x'] >= buffer.width) {
					vertex['x'] = buffer.width;
				}
				if (vertex['x'] < 0) {
					vertex['x'] = 0;
				}
			}

			var FRICTION_THRESHOLD = 3;

			// Continued motion and bounds checking
			for (i = 0; i < vertices.length; i++) {
				vertex = vertices[i];
				var newPrevX = vertex['x'];
				var newPrevY = vertex['y'];
				vertex['y'] += vertex['y'] - vertex['prevY'];

				// Can't move so well if touching ground?
				if (Math.abs(vertex['y'] - buffer.height) < FRICTION_THRESHOLD) {
					vertex['x'] += 0;//(vertex['x'] - vertex['prevX']) * 1.01;
				} else {
					vertex['x'] += vertex['x'] - vertex['prevX'];
				}

				vertex['prevX'] = newPrevX;
				vertex['prevY'] = newPrevY;
			}
		}

		public function fitness() {
			var i, vertex, maxX = 0;
			for (i = 0; i < vertices.length; i++) {
				vertex = vertices[i];
				maxX = Math.max(vertex['x'], maxX);
			}
			trace('Reporting ' + maxX + ' as fitness');
			return maxX;
		}

		public function render() {
			buffer.fillRect(new Rectangle(0, 0, buffer.width, buffer.height), 0xff577AB1);
			for (var i = 0; i < vertices.length; i++) {
				var vertex = vertices[i];
				buffer.copyPixels(
					spritesheetBitmapData,
					new Rectangle(0 + vertex['sprite'] * 32, 0, 32, 32),
					new Point(vertex['x'] - 32/2, vertex['y'] - 32/2),
					null,
					new Point(0,0),
					true
				);
			}
		}

		public function addCreature(creature:Creature) {
		}
	}
}

