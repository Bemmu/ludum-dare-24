package {
	import flash.display.*;
	import flash.geom.*;

	public class Simulation {
		var vertices;
		var bounds;
		var gravity = 0.08;
		var buffer;

		public function Simulation(buffer:BitmapData) {
			this.buffer = buffer;
			vertices = [
				{'x' : 10, 'y' : 10, 'prevX' : 9, 'prevY' : 10}
			];
		}

		public function tick() {
			for (var i = 0; i < vertices.length; i++) {
				var vertex = vertices[i];
				var newPrevX = vertex['x'];
				var newPrevY = vertex['y'];
				vertex['x'] += vertex['x'] - vertex['prevX'];
				vertex['y'] += vertex['y'] - vertex['prevY'];
				vertex['y'] += gravity;
				vertex['prevX'] = newPrevX;
				vertex['prevY'] = newPrevY;
			}
		}

		public function render() {
			buffer.fillRect(new Rectangle(0, 0, buffer.width, buffer.height), 0xff000000);
			for (var i = 0; i < vertices.length; i++) {
				var vertex = vertices[i];
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

