﻿/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author or authors.
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
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Edge3D;
	import sandy.core.data.Polygon;
	import sandy.core.scenegraph.Sprite2D;
	import sandy.materials.Material;
	
	/**
	 * Holds all outline attributes data for a material.
	 *
	 * <p>Each material can have an outline attribute to outline the whole 3D shape.<br/>
	 * The OutlineAttributes class stores all the information to draw this outline shape</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		09.09.2007
	 */
	public final class OutlineAttributes extends AAttributes
	{
		private const SHAPE_MAP:Dictionary = new Dictionary(true);
		// --
		private var m_nThickness:Number;
		private var m_nColor:Number;
		private var m_nAlpha:Number;
		// --
		public var modified:Boolean;
		
		/**
		 * Creates a new OutlineAttributes object.
		 *
		 * @param p_nThickness	The line thickness - Defaoult 1
		 * @param p_nColor	The line color - Default 0 ( black )
		 * @param p_nAlpha	The alpha value in percent of full opacity ( 0 - 1 )
		 */
		public function OutlineAttributes( p_nThickness:uint = 1, p_nColor:uint = 0, p_nAlpha:Number = 1 )
		{
			m_nThickness = p_nThickness;
			m_nAlpha = p_nAlpha;
			m_nColor = p_nColor;
			// --
			modified = true;
		}
		
		/**
		 * @private
		 */
		public function get alpha():Number
		{
			return m_nAlpha;
		}
		
		/**
		 * @private
		 */
		public function get color():Number
		{
			return m_nColor;
		}
		
		/**
		 * @private
		 */
		public function get thickness():Number
		{
			return m_nThickness;
		}
		
		/**
		 * The alpha value for the lines ( 0 - 1 )
		 *
		 * Alpha = 0 means fully transparent, alpha = 1 fully opaque.
		 */
		public function set alpha(p_nValue:Number):void
		{
			m_nAlpha = p_nValue; 
			modified = true;
		}
		
		/**
		 * The line color
		 */
		public function set color(p_nValue:Number):void
		{
			m_nColor = p_nValue; 
			modified = true;
		}

		/**
		 * The line thickness
		 */	
		public function set thickness(p_nValue:Number):void
		{
			m_nThickness = p_nValue; 
			modified = true;
		}
		
		/**
		 * Allows to proceed to an initialization
		 * to know when the polyon isn't lined to the material, look at #unlink
		 */
		override public function init( p_oPolygon:Polygon ):void
		{
			;// to keep reference to the shapes/polygons that use this attribute
			// -- attempt to create the neighboors relation between polygons
			if( SHAPE_MAP[p_oPolygon.shape.id] == null )
			{
		        // if this shape hasn't been registered yet, we compute its polygon relation to be able
		        // to draw the outline.
		        var l_aPoly:Array = p_oPolygon.shape.aPolygons;
		        var a:int = l_aPoly.length, lCount:uint = 0, i:int, j:int;
		        var lP1:Polygon, lP2:Polygon;
		        var l_aEdges:Array;
		        for( i = 0; i < a-1; i+=1 )
		        {
		        	lP1 = l_aPoly[int(i)];
		        	for( j=i+1; j < a; j+=1 )
			        {
			        	lP2 = l_aPoly[int(j)];
			        	l_aEdges = lP2.aEdges;
			        	// --
			        	lCount = 0;
			        	// -- check if they share at least 2 vertices
			        	for each( var l_oEdge:Edge3D in lP1.aEdges )
			        		if( l_aEdges.indexOf( l_oEdge ) > -1 ) lCount += 1;
			        	// --
			        	if( lCount > 0 )
			        	{
			        		lP1.aNeighboors.push( lP2 );
			        		lP2.aNeighboors.push( lP1 );
			        	}
			        }
				}
				// --
				SHAPE_MAP[p_oPolygon.shape.id] = true;
			}
		}
	
		/**
		 * Remove all the initialization
		 * opposite of init
		 */
		override public function unlink( p_oPolygon:Polygon ):void
		{
			;// to remove reference to the shapes/polygons that use this attribute
			// TODO : can we free the memory of SHAPE_MAP ? Don't think so, and would it be really necessary? not sure either.
		}
		
		/**
		 * Draw the outline edges of the polygon into the graphics object.
		 *  
		 * @param p_oGraphics the Graphics object to draw attributes into
		 * @param p_oPolygon the polygon which is going to be drawn
		 * @param p_oMaterial the refering material
		 * @param p_oScene the scene
		 */
		override public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			var l_oEdge:Edge3D;
			var l_oPolygon:Polygon;
			var l_bFound:Boolean;
			// --
			p_oGraphics.lineStyle( m_nThickness, m_nColor, m_nAlpha );
			p_oGraphics.beginFill(0);
			// --
			for each( l_oEdge in p_oPolygon.aEdges )
        	{
        		l_bFound = false;
        		// --
        		for each( l_oPolygon in p_oPolygon.aNeighboors )
				{
	        		// aNeighboor not visible, does it share an edge?
					// if so, we draw it
					if( l_oPolygon.aEdges.indexOf( l_oEdge ) > -1 )
	        		{
						if( l_oPolygon.visible == false )
						{
							p_oGraphics.moveTo( l_oEdge.vertex1.sx, l_oEdge.vertex1.sy );
							p_oGraphics.lineTo( l_oEdge.vertex2.sx, l_oEdge.vertex2.sy );
						}
						l_bFound = true;
					}
	   			}
	   			// -- if not shared with any neighboor, it is an extremity edge that shall be drawn
	   			if( l_bFound == false )
	   			{
		   			p_oGraphics.moveTo( l_oEdge.vertex1.sx, l_oEdge.vertex1.sy );
					p_oGraphics.lineTo( l_oEdge.vertex2.sx, l_oEdge.vertex2.sy );
	   			}
			}

			p_oGraphics.endFill();
		}

		/**
		 * Outline the sprite. This has to clear any drawing done on sprite container, sorry.
		 *  
		 * @param p_oSprite the Sprite2D object to apply attributes to
		 * @param p_oScene the scene
		 */
		override public function drawOnSprite( p_oSprite:Sprite2D, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			const g:Graphics = p_oSprite.container.graphics; g.clear ();
			const r:Rectangle = p_oSprite.container.getBounds (p_oSprite.container);
			g.lineStyle (m_nThickness, m_nColor, m_nAlpha); g.drawRect (r.x, r.y, r.width, r.height);
		}
	}
}