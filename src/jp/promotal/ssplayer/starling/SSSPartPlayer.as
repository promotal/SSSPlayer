package jp.promotal.ssplayer.starling {

	import flash.geom.Matrix;

	import jp.promotal.ssplayer.data.SSCell;
	import jp.promotal.ssplayer.data.SSModel;
	import jp.promotal.ssplayer.data.SSPartAnime;
	import jp.promotal.ssplayer.data.SSProject;
	import jp.promotal.ssplayer.data.SSPart;
	import jp.promotal.ssplayer.utils.SSColor;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;

	public class SSSPartPlayer extends Sprite {

		private var project:SSProject;

		private var model:SSModel;

		private var parentPartPlayer:SSSPartPlayer;

		private var image:Image;

		private var _color:SSColor = new SSColor(0xffffffff);
		public function get color():uint {
			return this._color.value;
		}
		public function set color(value:uint):void {
			this._color.value = value;
		}

		private var _part:SSPart;
		public function get part():SSPart {
			return _part;
		}

		private var partAnime:SSPartAnime;

		private var _cell:SSCell;
		public function get cell():SSCell {
			return this._cell;
		}
		public function set cell(value:SSCell):void {
			this._cell = value;
			if (value) {
				this.texture = value.texture;
				this.image.x = -value.pivotX;
				this.image.y = -value.pivotY;
			} else {
				this.texture = null;
			}
		}

		public function get cellName():String {
			return this._cell ? this._cell.name : null;
		}

		private var _texture:Texture;
		private function set texture(value:Texture):void {
			this._texture = value;
			if (value) {
				if (this.image) {
					this.image.visible = true;
					this.image.texture = value;
				} else {
					this.image = new Image(value);
					this.addChild(this.image);
				}
			} else if (this.image) {
				this.image.visible = false;
			}
		}

		public function get partName():String {
			return this._part.name;
		}

		public function SSSPartPlayer(project:SSProject, model:SSModel, part:SSPart, partAnime:SSPartAnime, parentPartPlayer:SSSPartPlayer) {
			super();
			this.project = project;
			this.model = model;
			this._part = part;
			this.partAnime = partAnime;
			this.parentPartPlayer = parentPartPlayer;
		}

		public function set currentFrame(value:Number):void {
			if (!this.partAnime) {
				return;
			}
			switch (this._part.type) {
				case "normal":
					var cellName:String = this.partAnime.attribute("CELL").valueAt(value);
					cellName = this.model.cellmapName(int(cellName.split("/")[0])) + "/" + cellName.split("/")[1];
					this.cell = this.part.show != 0 ? this.project.cell(cellName) : null;
					var matrix:Matrix = new Matrix();
					matrix.scale(
						parseFloat(this.partAnime.attribute("SCLX").valueAt(value) || "1"),
						parseFloat(this.partAnime.attribute("SCLY").valueAt(value) || "1")
					);
					matrix.rotate(-(parseFloat(this.partAnime.attribute("ROTZ").valueAt(value)) || 0) / 180 * Math.PI);
					matrix.translate(
						(parseFloat(this.partAnime.attribute("POSX").valueAt(value))) || 0,
						-(parseFloat(this.partAnime.attribute("POSY").valueAt(value))) || 0
					);
					if (this.parentPartPlayer) {
						matrix.concat(this.parentPartPlayer.transformationMatrix);
					}
					if (this.image) {
						this.image.visible = true;//String(this.partAnime.attribute("HIDE").valueAt(value)) != "1";
						var alpha:Number = parseFloat(this.partAnime.attribute("ALPH").valueAt(value) || "1");
						this.image.alpha = alpha;
						this.image.color = this._color.value;
					}
					this.transformationMatrix = matrix;
					break;
			}
			if (false && this.image) {
				trace([
					this.partName,
					this.cell.pivot,
					this.cell.pivotX,
					this.cell.pivotY
				].join(","));
			}
		}
	}
}