package {

	import flash.display.*
	import flash.events.*

	import sandy.core.*; 
	import sandy.core.data.*; 
	import sandy.core.scenegraph.*; 
	import sandy.primitive.*; 
	import sandy.materials.*; 
	import sandy.view.*;

	[SWF (width=465, height=465, backgroundColor=0x0, frameRate=20)]
	public class BitmapTiling extends BasicView {

		public var mat:BitmapMaterial;

		public function BitmapTiling () {
			super (); init (465, 465); render ();

			var b:BitmapData = new BitmapData (2, 2, false, 0xFFFFFF);
			b.setPixel (0, 0, 0); b.setPixel (1, 1, 0);

			var p:Plane3D = addVerticalPlane ();
			p.appearance = makeBitmapAppearance (b);
			mat = BitmapMaterial (p.appearance.frontMaterial);
		}

		override public function simpleRender(e:Event = null):void {
			var r:Number = Math.random (); mat.setTiling (r, r); super.simpleRender (e);
		}
	}
}