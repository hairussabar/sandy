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
	
	import sandy.core.SandyFlags;
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.data.Vector;
	import sandy.core.data.Vertex;
	import sandy.materials.Material;
	import sandy.util.NumberUtil;
	
	/**
	 * Realize a flat shading effect when associated to a material.
	 *
	 * <p>To make this material attribute use by the Material object, the material must have :myMAterial.lightingEnable = true.<br />
	 * This attributes contains some parameters</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public final class LightAttributes extends ALightAttributes
	{
		/**
		 * Flag for lightening mode.
		 * <p>If true, the lit objects use full light range from black to white.<b />
		 * If false (the default) they just range from black to their normal appearance.</p>
		 */
		public var useBright:Boolean = false;
		
		/**
		 * Creates a new LightAttributes object.
		 *
		 * @param p_bBright The brightness (value for useBright).
		 * @param p_nAmbient The ambient light value. Value must be between 0 and 1
		 */
		public function LightAttributes( p_bBright:Boolean = false, p_nAmbient:Number = 0.3 )
		{
			useBright = p_bBright;
			ambient = NumberUtil.constrain( p_nAmbient, 0, 1 );
			m_nFlags |= SandyFlags.POLYGON_NORMAL_WORLD;
		}
		
		/**
		 * Draw the attribute onto the graphics object to simulate the flat shading.
		 *  
		 * @param p_oGraphics the Graphics object to draw attributes into
		 * @param p_oPolygon the polygon which is going o be drawn
		 * @param p_oMaterial the refering material
		 * @param p_oScene the scene
		 */
		override public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			super.draw (p_oGraphics, p_oPolygon, p_oMaterial, p_oScene);

			if( p_oMaterial.lightingEnable )
			{	
				var l_aPoints:Array = (p_oPolygon.isClipped)?p_oPolygon.cvertices : p_oPolygon.vertices;
				var l_oNormal:Vector = p_oPolygon.normal.getWorldVector();
				// --
				var lightStrength:Number = NumberUtil.constrain (calculate (l_oNormal, p_oPolygon.visible), 0, 1);
				// --
				p_oGraphics.lineStyle();
				if( useBright) 
					p_oGraphics.beginFill( (lightStrength < 0.5) ? 0 : 0xFFFFFF, (lightStrength < 0.5) ? (1-2 * lightStrength) : (2 * lightStrength - 1) );
				else 
					p_oGraphics.beginFill( 0, 1-lightStrength );
				// --
				p_oGraphics.moveTo( l_aPoints[0].sx, l_aPoints[0].sy );
				for each( var l_oVertex:Vertex in l_aPoints )
				{
					p_oGraphics.lineTo( l_oVertex.sx, l_oVertex.sy );
				}
				p_oGraphics.endFill();
				// --
				l_oNormal = null;
				l_oVertex = null;
			}
		}
	}
}
