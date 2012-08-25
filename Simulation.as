package {
	import flash.display.*;
	import flash.geom.*;

	public class Simulation {
		var vertices;
		var bounds;
		var joints;
		var gravity = 0.12;
		var buffer;

		// Different types of vertices like head, foot, hand just to make it look more human.

		public function Simulation(buffer:BitmapData) {
			this.buffer = buffer;
			vertices = [
				{'x' : 10, 'y' : 70, 'prevX' : 10, 'prevY' : 70},
				{'x' : 50, 'y' : 10, 'prevX' : 50, 'prevY' : 10},
				{'x' : 90, 'y' : 70, 'prevX' : 90, 'prevY' : 70}
			];

			joints = [
				{'a' : 0, 'middle' : 1, 'b' : 2, 'desiredAngle' : Math.PI/2} // index of participants in this joint and desired angle to keep between them
			];
		}

		public function tick() {
			var i, vertex;

			// Apply gravity
			for (i = 0; i < vertices.length; i++) {
				vertex = vertices[i];
				vertex['y'] += gravity;
			}

			// Angular joints
			for (i = 0; i < joints.length; i++) {
				var joint = joints[i];

				var ax = vertices[joint['a']]['x'];
				var ay = vertices[joint['a']]['y'];
				var bx = vertices[joint['b']]['x'];
				var by = vertices[joint['b']]['y'];
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

				// Angle not enough? Add a tad.
				if (bangle < desiredAngle) {
					aangle -= (desiredAngle - bangle)/2;
					bangle += (desiredAngle - bangle)/2;
				}
				if (bangle > desiredAngle) {
					aangle += -(desiredAngle - bangle)/2;
					bangle -= +(desiredAngle - bangle)/2;
				}

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

			// Continued motion and bounds checking
			for (i = 0; i < vertices.length; i++) {
				vertex = vertices[i];
				var newPrevX = vertex['x'];
				var newPrevY = vertex['y'];
				vertex['x'] += vertex['x'] - vertex['prevX'];
				vertex['y'] += vertex['y'] - vertex['prevY'];
				vertex['prevX'] = newPrevX;
				vertex['prevY'] = newPrevY;

				if (vertex['y'] > buffer.height) {
					var tmp = vertex['prevY'];
					vertex['prevY'] = vertex['y'];
					vertex['y'] = tmp;
				}
			}
		}

		public function render() {
			buffer.fillRect(new Rectangle(0, 0, buffer.width, buffer.height), 0xff000000);
			for (var i = 0; i < vertices.length; i++) {
				var vertex = vertices[i];
				buffer.setPixel(
					vertex['x'], vertex['y'],
					0xffffffff
				);
			}
		}

		public function addCreature(creature:Creature) {
		}
	}
}

