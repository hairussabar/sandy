/*
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

package sandy.primitive {

	import sandy.core.data.Vertex;
	import sandy.core.data.UVCoord;
	import sandy.core.Object3D;
	import sandy.primitive.Primitive3D;
	
	import sandy.core.face.IPolygon;
	import sandy.core.face.Polygon;
	import sandy.events.SandyEvent;
	import sandy.core.Geometry3D;

	

	/**
	* Box
	*
	* <p>Box is a primitiv Object3D, to easy build a Cube/Box.</p>
	* 
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		12.07.2006 
	**/
	public class Box extends Object3D implements Primitive3D
	{

		
		/**
		* height of the Box
		*/ 
		private var _h	: Number;

		/**
		* depth of the Box
		*/ 
		private var _lg : Number;

		/**
		* wide of the Box
		*/ 
		private var _radius : Number ;
		
		private var _q:Number;
		
		/*
		 * Mode with 3 or 4 points per face
		 */
		 private var _mode : String;
		 
		
		
		
		/**
		* Constructor
		*
		* <p>This is the constructor to call when you nedd to create a Box primitiv.</p>
		*
		* <p>This method will create a complete object with vertex,
		*    normales, texture coords and the faces.
		*    So it allows to have a custom 3D object easily</p>
		*
		* @param rad a Number represent the wide of the Box
		* @param h a Number represent the height of the Box
		* @param lg a Number represent the depth of the Box
		* @param mode String represent the two available modes to generates the faces.
		* "tri" is necessary to have faces with 3 points, and "quad" for 4 points.
		*/
		public function Box ( rad:Number = 100, h:Number = 6, lg:Number = 6, mode:String = 'tri', quality:int = 1)
		{
			super ();
			
			_h = h ;
			_lg = lg ;
			_radius = rad ;
			_q = (quality <= 0 || quality > 10) ?  1 : quality ;
			_mode = ( mode != 'tri' && mode != 'quad' ) ? 'tri' : mode;
			generate ();
		}
		
		/**
		* generate
		* 
		* <p>Generate all is needed to construct the Object3D : </p>
		* <ul>
		* 	<li>{@link Vertex}</li>
		* 	<li>{@link UVCoords}</li>
		* 	<li>{@link TriFace3D}</li>
		* </ul>
		* <p>It can construct dynamically the object, taking care of your preferences given in arguments. <br/>
		*    Note in Sandy 0.1 all faces have only three points.
		*    This will change in the future version, 
		*    and give to you the possibility to choose n points per faces</p> 
		*/
		public function generate () : void
		{
			// initialisation
			var l_geometry:Geometry3D = geometry;
			
			//we build points
			var h2 : Number = - _h / 2;
			var r2 : Number = _radius / 2;
			var l2 : Number = _lg / 2;

			var p0 : Vertex = new Vertex (-r2,-h2,l2);
			l_geometry.addPoint(p0);
			var p1 : Vertex = new Vertex (r2,-h2,l2);
			l_geometry.addPoint(p1);
			var p2 : Vertex = new Vertex (r2,h2,l2);
			l_geometry.addPoint(p2);
			var p3 : Vertex = new Vertex (-r2,h2,l2);
			l_geometry.addPoint(p3);
			var p4 : Vertex = new Vertex (-r2,-h2,-l2);
			l_geometry.addPoint(p4);
			var p5 : Vertex = new Vertex (r2,-h2,-l2);
			l_geometry.addPoint(p5);
			var p6 : Vertex = new Vertex (r2,h2,-l2);
			l_geometry.addPoint(p6);
			var p7 : Vertex = new Vertex (-r2,h2,-l2);
			l_geometry.addPoint(p7);
			
			// -- we setup texture coordinates
			var uv0:UVCoord = new UVCoord (0, 0);
			var uv1:UVCoord = new UVCoord (1, 0);
			var uv2:UVCoord = new UVCoord (0, 1);
			var uv3:UVCoord = new UVCoord (1, 1);
			
			// -- Faces creation
			
			//Front Face
			__tesselate(p0, p1, p2, p3,
						uv0, uv1, uv3, uv2,
						_q - 1 );
			
			//Behind Face
			__tesselate(p4, p7, p6, p5,
						uv1, uv3, uv2, uv0,
						_q - 1 );
			//Top Face
			__tesselate(p2, p6, p7, p3,
						uv1, uv3, uv2, uv0,
						_q - 1 );
			//Bottom Face
			__tesselate(p0, p4, p5, p1,
						uv2, uv3, uv1, uv0,
						_q - 1 );
			//Left Face
			__tesselate(p0, p3, p7, p4,
						uv1, uv3, uv2, uv0,
						_q - 1 );
			//Right Face
			__tesselate(p1, p5, p6, p2,
						uv0, uv1, uv3, uv2,
						_q - 1 );
						

		}
		
		private function __tesselate( 	p0:Vertex, p1:Vertex, p2:Vertex, p3:Vertex,
										uv0:UVCoord, uv1:UVCoord, uv2:UVCoord, uv3:UVCoord,
										level:int):void
		{
			var l_geometry:Geometry3D = geometry;
			
			var f:IPolygon;
			if(level == 0 ) // End of recurssion
			{
				// -- We have the same normal for 2 faces, be careful to don't add extra normal
				if( _mode == 'tri' )
				{
					//Front Face
					l_geometry.createFace( p0, p1, p3 );
					l_geometry.addUVCoords( uv0, uv1, uv3 );
					
					l_geometry.createFace( p2, p3, p1 );
					l_geometry.addUVCoords( uv2, uv3, uv1 );
					
				}
				else if( _mode == 'quad' )
				{
					//Front Face
					l_geometry.createFace( p0, p1, p2, p3 );
					l_geometry.addUVCoords( uv0, uv1, uv2 );
				}
			}
			else
			{
				//milieu de p0, p1;
				var m01:Vertex = new Vertex( (p0.x+p1.x)/2, (p0.y+p1.y)/2, (p0.z+p1.z)/2 );
				l_geometry.addPoint(m01);
				// milieu de p1 p2
				var m12:Vertex = new Vertex( (p1.x+p2.x)/2, (p1.y+p2.y)/2, (p1.z+p2.z)/2 );
				l_geometry.addPoint(m12);
				// milieu de p2 p3
				var m23:Vertex = new Vertex( (p2.x+p3.x)/2, (p2.y+p3.y)/2, (p2.z+p3.z)/2 );
				l_geometry.addPoint(m23);
				// milieu de p3 p0
				var m30:Vertex = new Vertex( (p3.x+p0.x)/2, (p3.y+p0.y)/2, (p3.z+p0.z)/2 );
				l_geometry.addPoint(m30);
				// milieu tout court
				var center:Vertex = new Vertex( (p0.x+p1.x+p2.x+p3.x)/4, (p0.y+p1.y+p2.y+p3.y)/4, (p0.z+p1.z+p2.z+p3.z)/4 );
				l_geometry.addPoint(center);
				//l_geometry.addPoints( m01, m12, m23, m30, center );
				
				
				//milieu de p0, p1;
				var uv01:UVCoord = new UVCoord ((uv0.u+uv1.u)/2, (uv0.v+uv1.v)/2);
				// milieu de p1 p2
				var uv12:UVCoord = new UVCoord ( (uv1.u+uv2.u)/2, (uv1.v+uv2.v)/2 );
				// milieu de p2 p3
				var uv23:UVCoord = new UVCoord ( (uv2.u+uv3.u)/2, (uv2.v+uv3.v)/2 );
				// milieu de p3 p0
				var uv30:UVCoord = new UVCoord ( (uv3.u+uv0.u)/2, (uv3.v+uv0.v)/2 );
				// milieu tout court
				var uvcenter:UVCoord = new UVCoord ( (uv0.u+uv1.u+uv2.u+uv3.u)/4, (uv0.v+uv1.v+uv2.v+uv3.v)/4);

				
				
				__tesselate(center, m30, p0, m01,
							uvcenter, uv30, uv0, uv01,
							level - 1 );
				__tesselate(center, m01, p1, m12,
							uvcenter, uv01, uv1, uv12,
							level - 1 );
				
				__tesselate(center, m12, p2, m23,
							uvcenter, uv12, uv2, uv23,
							level - 1 );
				
				__tesselate(center, m23, p3, m30,
							uvcenter, uv23, uv3, uv30,
							level - 1 );
				
			}
		}
		
	}
}