package {
	import flash.display.*;
	import flash.geom.*;

	public class Simulation {
		var vertices;
		var bounds;
		var angularJoints;
		var springs;
		var gravity = 0.12;
		var buffer;
		var spritesheetBitmapData;
		var tickCounter = 0;

		// Different types of vertices like head, foot, hand just to make it look more human.

		public function Simulation(buffer:BitmapData, spritesheetBitmapData:BitmapData) {
			this.buffer = buffer;
			this.spritesheetBitmapData = spritesheetBitmapData;

			vertices = [
				{'x' : 50, 'y' : 40, 'sprite' : 1}, // torso 0
				{'x' : 50, 'y' : 60, 'sprite' : 0}, // hips 1
				{'x' : 30, 'y' : 100, 'sprite' : 0}, // left leg 2
				{'x' : 70, 'y' : 100, 'sprite' : 0} // right leg 3

//				{'x' : 50, 'y' : 18}, // head
//				{'x' : 15, 'y' : 40}, // left hand
//				{'x' : 85, 'y' : 40}, // right hand

/*				{'x' : 10, 'y' : 10, 'prevX' : 10, 'prevY' : 10},
				{'x' : 70, 'y' : 10, 'prevX' : 70, 'prevY' : 10}*/
			];

			angularJoints = [
//				{'a' : 2, 'middle' : 1, 'b' : 3, 'amplitude' : 0, 'frequency' : 0.1},
//				{'a' : 0, 'middle' : 1, 'b' : 2, 'amplitude' : 0, 'frequency' : 0.01}
			];

			springs = [
				// Skeleton
				{'a' : 0, 'b' : 1},
				{'a' : 1, 'b' : 2, 'amplitude' : 10, 'frequency' : 0.1},
				{'a' : 1, 'b' : 3, 'amplitude' : 10, 'frequency' : 0.1},

				// Leg distance enforcer
				{'a' : 2, 'b' : 3, 'elasticity' : 0.2},

				// Torso distance enforcer
				{'a' : 2, 'b' : 0, 'elasticity' : 0.2},
				{'a' : 3, 'b' : 0, 'elasticity' : 0.2}
			];

			var i, vertex, spring, joint;

			var xPush = 2, yPush = 0;

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

			// Be satisfied by the initial angles between angular joints
			initOrTickAngularJoints();
		}

		function initOrTickAngularJoints() {
			var i, ax, ay, bx, by;

			// Angular joints
			for (i = 0; i < angularJoints.length; i++) {
				var joint = angularJoints[i];

				ax = vertices[joint['a']]['x'];
				ay = vertices[joint['a']]['y'];
				bx = vertices[joint['b']]['x'];
				by = vertices[joint['b']]['y'];

				var middlex = vertices[joint['middle']]['x'];
				var middley = vertices[joint['middle']]['y'];
				var desiredAngle = joint['desiredAngle'];

				ax -= middlex; ay -= middley;
				bx -= middlex; by -= middley;

				// Snap to unit circle
				var ascale = Math.sqrt(ax*ax + ay*ay);
				var bscale = Math.sqrt(bx*bx + by*by);
				ax /= ascale; ay /= ascale;
				bx /= bscale; by /= bscale;

				// Rotate so that a is horizontal
				var aangle = Math.atan2(ay, ax);
				var bangle = Math.atan2(by, bx);

				var rotation = aangle;
				aangle -= rotation;
				bangle -= rotation;

				// Clip bangle to -Math.PI .. Math.PI range
				var clipped = bangle;
//				while (clipped < -Math.PI) clipped += Math.PI * 2;
//				while (clipped >= Math.PI) clipped -= Math.PI * 2;

				trace(clipped);

				if (!desiredAngle) {
					joint['desiredAngle'] = clipped;
					return
				}

/*				var waviness = Math.sin(tickCounter * joint['frequency']) * joint['amplitude'];
				desiredAngle += waviness;
*/
				// Angle not enough? Add a tad.
				var angleChange = (desiredAngle - clipped)/2;

				if (angleChange > 1) {
					trace('aangle:' + aangle);
					trace('bangle:' + bangle);
					trace('rotation:' + rotation);
					trace(angleChange);
				}

				aangle -= angleChange;
				bangle += angleChange;

				// Now rewind operations.
				aangle += rotation;
				bangle += rotation;
				ax = Math.cos(aangle) * ascale + middlex;
				ay = Math.sin(aangle) * ascale + middley;
				bx = Math.cos(bangle) * bscale + middlex;
				by = Math.sin(bangle) * bscale + middley;

				vertices[joint['a']]['x'] = ax;
				vertices[joint['a']]['y'] = ay;
				vertices[joint['b']]['x'] = bx;
				vertices[joint['b']]['y'] = by;
			}

		}

		public function tick() {
//			return;

			var i, vertex, ax, ay, bx, by;
			tickCounter++;

			// Apply gravity
			for (i = 0; i < vertices.length; i++) {
				vertex = vertices[i];
				vertex['y'] += gravity;
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
					var waviness = Math.sin(spring['frequency'] * tickCounter) * spring['amplitude'];
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

			initOrTickAngularJoints();

			// Bounds checking
			for (i = 0; i < vertices.length; i++) {
				vertex = vertices[i];
				if (vertex['y'] >= buffer.height) {
					vertex['y'] = buffer.height;
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

			// Continued motion and bounds checking
			for (i = 0; i < vertices.length; i++) {
				vertex = vertices[i];
				var newPrevX = vertex['x'];
				var newPrevY = vertex['y'];
				vertex['x'] += vertex['x'] - vertex['prevX'];
				vertex['y'] += vertex['y'] - vertex['prevY'];
				vertex['prevX'] = newPrevX;
				vertex['prevY'] = newPrevY;
			}
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

				buffer.setPixel(
					vertex['x'], vertex['y'],
					0xff000000
				);
			}
		}

		public function addCreature(creature:Creature) {
		}
	}
}

