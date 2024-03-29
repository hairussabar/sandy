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

import flash.geom.Point;
import flash.geom.Rectangle;

import sandy.core.data.Matrix4;
import sandy.core.data.PrimitiveFace;
import sandy.core.data.Vector;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.extrusion.data.Polygon2D;

/**
 * Very basic extrusion class.
 *
 * @author		makc
 * @author		(porting) Floris - xdevltd
 * @version		2.0.2
 * @date		03.10.2008
 */
 
class sandy.extrusion.Extrusion extends Shape3D 
{

	/**
	 * Extrudes 2D polygon.
	 *
	 * @param  name 		Shape name.
	 * @param  profile 		Polygon to extrude.
	 * @param  sections 	Array of transformation matrices.
	 * @param  closeFront 	Flag to close extrusion front end.
	 * @param  closeBack 	Flag to close extrusion back end.
	 *
	 * @see Matrix4
	 * @see Polygon2D
	 */
	public function Extrusion( name:String, profile:Polygon2D, sections:Array, closeFront:Boolean, closeBack:Boolean )
	{
		if( closeFront == null ) closeFront = true;
		if( closeBack == null ) closeBack = true;
			
		var i:Number, j:Number, k:Number, g:Geometry3D = new Geometry3D, v:Vector = new Vector;

		// arrays to store face IDs
		var backFaceIDs:Array = [], frontFaceIDs:Array = [], sideFaceIDs:Array = [];
		
		// find links
		// 2nd vertex in link edge goes to array
		var links:Array = [], n:Number = profile.vertices.length;
		for( i = 1; i < n + 1; i++ )
		for( j = 1; j < n + 1; j++ ) 
		{
			if( ( Point.distance( profile.vertices[ i % n ], profile.vertices[ j - 1 ] ) == 0 ) &&
			 	( Point.distance( profile.vertices[ j % n ], profile.vertices[ i - 1 ] ) == 0 ) ) links.push( profile.vertices[ i ] );
		}
	
		// if no matrices are passed, use Identity
		if( sections == null ) sections = [];
		var l_sections:Array = sections.slice();   
		if( l_sections.length < 1 ) l_sections.push( new Matrix4 ); 

		// construct profile vertices and side surface, if any
		for( i = 0; i < l_sections.length; i++ )
		{
			var m:Matrix4 = Matrix4( l_sections[ i ] );
				
			for( j = 0; j < n; j++ )
			{
				v.x = profile.vertices[ j ].x;
				v.y = profile.vertices[ j ].y;
				v.z = 0;
				m.vectorMult( v );
				g.setVertex( j + i * n, v.x, v.y, v.z );
				g.setUVCoords( j + i * n, j / ( n - 1 ), i / ( l_sections.length - 1 ) );
			}
				
			if( i > 0 )
			{
				for( j = 1; j < n + 1; j++ )
				{
					if( links.indexOf( profile.vertices[ j % n ] ) < 0 )
					{
						k = g.getNextFaceID();
						g.setFaceVertexIds(k, j % n + i * n,
											  j + ( i - 1 ) * n - 1,
											  j + i * n - 1 );
						
						g.setFaceVertexIds( k + 1, j % n + i * n,
												   j % n + ( i - 1 ) * n,
												   j + ( i - 1 ) * n - 1 );
						
						g.setFaceUVCoordsIds( k, j % n + i * n,
												 j + ( i - 1 ) * n - 1,
												 j + i * n - 1 );
						
						g.setFaceUVCoordsIds( k + 1, j % n + i * n,
													 j % n + ( i - 1 ) * n,
													 j + ( i - 1 ) * n - 1 );
						
						sideFaceIDs.push( k, k + 1 );
					}
				}
			}
		}
		
		links.length = 0; links = null;

		if( closeFront || closeBack )
		{
			// profiles need separate UV mapping
			var p:Number = g.getNextUVCoordID();
			var b:Rectangle = profile.bbox();
			for( i = 0; i < profile.vertices.length; i++ )
				g.setUVCoords( p + i, ( profile.vertices[ i ].x - b.x ) / b.width, ( profile.vertices[ i ].y - b.y ) / b.height );

			// triangulate profile
			var triangles:Array = profile.triangles();

			var q:Number = g.getNextVertexID() - profile.vertices.length;
			for( var j in triangles )
			{
				var v1:Number = profile.vertices.indexOf( triangles[ j ].vertices[ 0 ] );
				var v2:Number = profile.vertices.indexOf( triangles[ j ].vertices[ 1 ] );
				var v3:Number = profile.vertices.indexOf( triangles[ j ].vertices[ 2 ] );

				if( closeFront )
				{
					// add front surface
					k = g.getNextFaceID();
					g.setFaceVertexIds( k, v1, v2, v3 );
					g.setFaceUVCoordsIds( k, p + v1, p + v2, p + v3 );
					frontFaceIDs.push( k );
				}

				if( closeBack ) 
				{
					// add back surface
					k = g.getNextFaceID();
					g.setFaceVertexIds( k, q + v1, q + v3, q + v2 );
					g.setFaceUVCoordsIds( k, p + v1, p + v3, p + v2 );
					backFaceIDs.push( k );
				}
			}
		}

		geometry = g;
		
		// generate faces
		_backFace = new PrimitiveFace( this );
		while( backFaceIDs.length > 0 ) _backFace.addPolygon( Number( backFaceIDs.pop() ) );

		_frontFace = new PrimitiveFace( this );
		while( frontFaceIDs.length > 0 ) _frontFace.addPolygon( Number( frontFaceIDs.pop() ) );

		_sideFace = new PrimitiveFace( this );
		while( sideFaceIDs.length > 0 ) _sideFace.addPolygon( Number( sideFaceIDs.pop() ) );
	}

	/**
	 * Collection of polygons on the back surface of extruded shape.
	 * Texture is mapped to fit profile bounding box on this face.
	 */
	public function get backFace() : PrimitiveFace { return _backFace; }
	private var _backFace:PrimitiveFace;

	/**
	 * Collection of polygons on the front surface of extruded shape.
	 * Texture is mapped to fit profile bounding box on this face.
	 */
	public function get frontFace() : PrimitiveFace { return _frontFace; }
	private var _frontFace:PrimitiveFace;

	/**
	 * Collection of polygons on the side surface of extruded shape.
	 * Texture U coordinate is mapped from 0 to 1 along the profile, and
	 * V coordinate is mapped from 0 at the front edge to 1 at the back edge.
	 */
	public function get sideFace() : PrimitiveFace { return _sideFace; }
	private var _sideFace:PrimitiveFace;
	
}