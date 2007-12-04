﻿/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author Thomas PFEIFFER
Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.mozilla.org/MPL/MPL-1.1.html
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# ***** END LICENSE BLOCK *****
*/

package sandy.materials.attributes
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;

	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.Material;
	import sandy.math.ColorMath;
	import sandy.math.VertexMath;
	
	/**
	 * This attribute provides very basic simulation of partially opaque medium.
	 * You can use this attribute to achieve wide range of effects (e.g., fog, Rayleigh scattering, light attached to camera, etc).
	 * 
	 * @author		makc
	 * @version		3.0
	 * @date 		01.12.2007
	 */
	public final class MediumAttributes implements IAttributes
	{
		/**
		 * Medium color (32-bit value) at the point given by fadeFrom + fadeTo.
		 * If this value is transparent, color gradient will be extrapolated beyond that point.
		 */
		public function set color (p_nColor:uint):void
		{
			_c = p_nColor & 0xFFFFFF;
			_a = (p_nColor - _c) / 0x1000000 / 255.0;
		}
		
		/**
		 * @private
		 */
		public function get color ():uint
		{
			return _c + Math.floor (0xFF * _a) * 0x1000000;
		}

		/**
		 * Attenuation vector. This is the vector from transparent point to opaque point.
		 */
		public function set fadeTo (p_oW:Vector):void
		{
			_fadeTo = p_oW;
			_fadeToN2 = p_oW.getNorm (); _fadeToN2 *= _fadeToN2;
		}
		
		/**
		 * @private
		 */
		public function get fadeTo ():Vector
		{
			return _fadeTo;
		}

		/**
		 * Transparent point in wx, wy and wz coordinates.
		 */
		public var fadeFrom:Vector;

		/**
		 * Maximum amount of blur to add.
		 */
		public var blurAmount:Number;

		/**
		 * Creates a new MediumAttributes object.
		 *
		 * @param p_nColor - Medium color (opaque white by default).
		 * @param p_oFadeTo - Attenuation vector (500 pixels beyond the screen by default).
		 * @param p_oFadeFrom - Transparent point (at the screen by default).
		 * @param p_nBlurAmount - Maximum amount of blur to add (0 by default).
		 */
		public function MediumAttributes (p_nColor:uint = 0xFFFFFFFF, p_oFadeFrom:Vector = null, p_oFadeTo:Vector = null, p_nBlurAmount:Number = 0)
		{
			if (p_oFadeFrom == null)
				p_oFadeFrom = new Vector (0, 0, 0);
			if (p_oFadeTo == null)
				p_oFadeTo = new Vector (0, 0, 500);
			// --
			color = p_nColor; fadeTo = p_oFadeTo; fadeFrom = p_oFadeFrom; blurAmount = p_nBlurAmount;
		}
		
		/**
		 * Draw the attribute onto the graphics object to simulate viewing through partially opaque medium.
		 *  
		 * @param p_oGraphics the Graphics object to draw attributes into
		 * @param p_oPolygon the polygon which is going o be drawn
		 * @param p_oMaterial the refering material
		 * @param p_oScene the scene
		 */
		public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			const l_points:Array = ((p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices);
			const n:int = l_points.length; if (n < 3) return;

			const l_ratios:Array = new Array (n);
			for (var i:int = 0; i < n; i++) l_ratios[i] = ratioFromWorldVector (l_points[i].getWorldVector ());

			const zIndices:Array = l_ratios.sort (Array.NUMERIC | Array.RETURNINDEXEDARRAY);

			const v0: Vertex = l_points[zIndices[0]];
			const v1: Vertex = l_points[zIndices[1]];
			const v2: Vertex = l_points[zIndices[2]];

			const r0: Number = l_ratios[zIndices[0]], ar0:Number = _a * r0;
			const r1: Number = l_ratios[zIndices[1]];
			const r2: Number = l_ratios[zIndices[2]], ar2:Number = _a * r2;

			if (ar2 > 0)
			{
				if (ar0 < 1)
				{
					// gradient matrix
					VertexMath.linearGradientMatrix (v0, v1, v2, r0, r1, r2, _m);

					p_oGraphics.beginGradientFill ("linear", [_c, _c], [ar0, ar2], [0, 0xFF], _m);
				}

				else
				{
					p_oGraphics.beginFill (_c, 1);
				}

				// --
				p_oGraphics.moveTo (l_points[0].sx, l_points[0].sy);
				for each (var l_oVertex:Vertex in l_points)
				{
					p_oGraphics.lineTo (l_oVertex.sx, l_oVertex.sy);
				}
				p_oGraphics.endFill();
			}

			blurPolygonBy (p_oPolygon, Math.min (255, Math.max (0, blurAmount * r0)));
		}

		/**
		 * Gives rough estimate for object alpha lower bound, if this attribute is applied.
		 *
		 * @example	You can use this method to save yourself few CPU cycles:
		 *
		 * <listing version="3.0">
		 * box.visible = (attr.getAlpha (box) > 0.2);
		 * </listing>
		 *
		 * @param p_oShape - object to estimate alpha lower bound for.
		 */
		public function getAlpha (p_oShape:Shape3D):Number
		{
			if (!p_oShape.boundingBox.uptodate || !p_oShape.visible)
				p_oShape.boundingBox.transform (p_oShape.viewMatrix);

			return Math.min (1, Math.max (0,
				1 - _a * ratioFromWorldVector (p_oShape.boundingBox.tmin) ));
		}

		// --
		private function ratioFromWorldVector (p_oW:Vector):Number
		{
			p_oW.sub (fadeFrom); return p_oW.dot (_fadeTo) / _fadeToN2;
		}

		private function blurPolygonBy (p_oPolygon:Polygon, p_nBlurAmount:Number):void
		{
			if (p_nBlurAmount == 0) return;

			var fs:Array = [], changed:Boolean = false, s:Sprite = p_oPolygon.container;
			for (var i:int = s.filters.length -1; i > -1; i--)
			{
				if (!changed && (s.filters[i] is BlurFilter) && (s.filters[i].quality == 1))
				{
					// hopefully, this check will save some cpu
					if ((s.filters[i].blurX == p_nBlurAmount) &&
					    (s.filters[i].blurY == p_nBlurAmount)) return;

					// assume this is our filter and replace it
					fs.push (new BlurFilter (p_nBlurAmount, p_nBlurAmount, 1));
					changed = true;
				}
				else
				{
					// copy the filter
					fs[i] = s.filters[i];
				}
			}
			// if filter was not found, add new
			if (!changed)
				fs.push (new BlurFilter (p_nBlurAmount, p_nBlurAmount, 1));
			// re-apply all filters
			s.filters = fs;
		}

		// --
		internal var _m:Matrix = new Matrix();
		internal var _c:uint;
		internal var _a:Number;
		internal var _fadeTo:Vector;
		internal var _fadeToN2:Number;
	}
}
