﻿/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author or authors.
Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 ( the "License" );
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
	
import flash.geom.Matrix;
import flash.geom.Point;

import sandy.core.Scene3D;
import sandy.core.data.Polygon;
import sandy.core.data.Vector;
import sandy.core.data.Vertex;
import sandy.core.light.Light3D;
import sandy.materials.Material;
import sandy.materials.attributes.ALightAttributes;
import sandy.materials.attributes.PhongAttributesLightMap;
import sandy.math.VertexMath;
import sandy.util.NumberUtil;

/**
 * Realize a Cell shading on a material.
 * <b>Note:</b> this class ignores all properties inherited from ALightAttributes!
 *
 * @author		rafajafar
 * @author		makc
 * @author		(porting) Floris - xdevltd
 */
 
class sandy.materials.attributes.CelShadeAttributes extends ALightAttributes
{
	
	/**
	 * Used if a lightmap needs to be overridden.
	 */
	public var lightmap:PhongAttributesLightMap;

	/**
	 * Non-zero value adds sphere normals to actual normals for light rendering.
	 * Use this with flat surfaces or cylinders.
	 */
	public var spherize:Number;

	/**
	 * Create the CelShadeAttributes object.
	 *
	 * @param p_oLightMap A lightmap that the object will use ( default map has four shades of gray ).
	 *
	 * @see PhongAttributesLightMap
	 */
	public function CelShadeAttributes( p_oLightMap:PhongAttributesLightMap )
	{
		spherize = 0;
		
		if( p_oLightMap )
		{
			lightmap = p_oLightMap;
		}
		else
		{
			lightmap = new PhongAttributesLightMap();
			lightmap.alphas[ 0 ] = [ 0.5, 0.5,
								     0.5, 0.5,
								     0.5, 0.5,
								     0.5, 0.5 ];
			lightmap.colors[ 0 ] = [ 0xFFFFFF, 0xFFFFFF ,
								     0x888888, 0x888888,
								     0x666666, 0x666666,
								     0x444444, 0x444444 ];
			lightmap.ratios[ 0 ] = [ 0, 40,
				  				    40, 80,
				  				    80, 120,
				 				    120, 180 ];
		}
		
		//-- define some variables
		aN = [ new Vector(), new Vector(), new Vector() ]; 
		aNP = [ new Point(), new Point(), new Point() ]; 

		dv = new Vector(); 
		e1 = new Vector();
		e2 = new Vector();

		matrix = new Matrix();
		matrix2 = new Matrix();
	}

	/**
	* @private
	*/
	public function draw( p_oMovieClip:MovieClip, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ) : Void
	{
		super.draw( p_oMovieClip, p_oPolygon, p_oMaterial, p_oScene );

		var i:Number, l_oVertex:Vertex,
			v:Vector,
			p:Point, p1:Point, p2:Point,
			m2a:Number, m2b:Number, m2c:Number, m2d:Number, a:Number;

		// got anything at all to do?
		if( !p_oMaterial.lightingEnable )
		{
			return;
		}

		// get vertices and prepare matrix2
		var l_aPoints:Array = ( p_oPolygon.isClipped ) ? p_oPolygon.cvertices : p_oPolygon.vertices;

		l_oVertex = l_aPoints[ 0 ];
		matrix2.tx = l_oVertex.sx; m2a = m2c = -l_oVertex.sx;
		matrix2.ty = l_oVertex.sy; m2b = m2d = -l_oVertex.sy;
		
		l_oVertex = l_aPoints[ 1 ];
		m2a += l_oVertex.sx; matrix2.a = m2a;
		m2b += l_oVertex.sy; matrix2.b = m2b;

		l_oVertex = l_aPoints[ 2 ];
		m2c += l_oVertex.sx; matrix2.c = m2c;
		m2d += l_oVertex.sy; matrix2.d = m2d;

		// transform 1st three normals
		// see if we are on the backside
		var backside:Boolean = true;
		for( i = 0; i < 3; i++ )
		{
			v = aN[ i ]; v.copy( Vertex( p_oPolygon.vertexNormals[ i ] ).getVector() );

			if( spherize > 0 )
			{
				l_oVertex = l_aPoints[ i ];

				dv.copy( l_oVertex.getVector() );
				dv.sub( p_oPolygon.shape.geometryCenter );
				dv.normalize();
				dv.scale( spherize );

				v.add( dv );
				v.normalize();
			}

			if( !p_oPolygon.visible ) v.scale( -1 );

			a = m_oCurrentL.dot( v ); if( a < 0 ) backside = false;

			// intersect with parabola - is it really needed here?
			v.scale( 1 / ( 1 - a ) );
		}

		if( backside )
		{
			// no reflection here - render the face in solid color
			var l:Number = lightmap.colors[ 0 ].length;
			var c:Number = int( lightmap.colors[ 0 ][ l - 1 ] );
			a = lightmap.alphas[ 0 ][ l - 1 ];
			p_oMovieClip.beginFill( c, a );
		}
		else
		{
			// calculate two arbitrary vectors perpendicular to light direction
			if( ( m_oL.x != 0 ) || ( m_oL.y != 0 ) )
			{
				e1.x = m_oCurrentL.y; e1.y = -m_oCurrentL.x; e1.z = 0;
			}
			else
			{
				e1.x = m_oCurrentL.z; e1.y = 0; e1.z = -m_oCurrentL.x;
			}
			e2.copy( m_oCurrentL ); e2.crossWith( e1 );
			e1.normalize();
			e2.normalize();

			for( i = 0; i < 3; i++ )
			{
				p = aNP[ i ]; v = aN[ i ];
				
				// project aN [ i ] onto e1 and e2
				p.x = e1.dot( v );
				p.y = e2.dot( v );

				// re-calculate into light map coordinates
				p.x = ( 16384 - 1 ) * 0.05 * p.x;
				p.y = ( 16384 - 1 ) * 0.05 * p.y;
			}

			// simple hack to resolve bad projections
			// where the hell do they keep coming from?
			p = aNP[ 0 ]; p1 = aNP[ 1 ]; p2 = aNP[ 2 ];
			a = ( p.x - p1.x ) * ( p.y - p2.y ) - ( p.y - p1.y ) * ( p.x - p2.x );
			while( ( -20 < a ) && ( a < 20 ) )
			{
				p.x--; p1.y++; p2.x++;
				a = ( p.x - p1.x ) * ( p.y - p2.y ) - ( p.y - p1.y ) * ( p.x - p2.x );
			}

			// compute gradient matrix
			matrix.a = p1.x - p.x;
			matrix.b = p1.y - p.y;
			matrix.c = p2.x - p.x;
			matrix.d = p2.y - p.y;
			matrix.tx = p.x;
			matrix.ty = p.y;
			matrix.invert();

			matrix.concat( matrix2 );
			p_oMovieClip.beginGradientFill( "radial", lightmap.colors[ 0 ], lightmap.alphas[ 0 ], lightmap.ratios[ 0 ], matrix );
		}

		// render the lighting
		p_oMovieClip.moveTo( l_aPoints[ 0 ].sx, l_aPoints[ 0 ].sy );
		for( l_oVertex in l_aPoints )
		{
			p_oMovieClip.lineTo( l_aPoints[ l_oVertex ].sx, l_aPoints[ l_oVertex ].sy  );
		}
		p_oMovieClip.endFill();

		// --
		l_aPoints = null;
	}

	// --
	private var aN:Array; 
	private var aNP:Array; 

	private var dv:Vector; 
	private var e1:Vector;
	private var e2:Vector; 

	private var matrix:Matrix; 
	private var matrix2:Matrix; 
	
}