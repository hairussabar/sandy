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
package sandy.primitive 
{
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.Shape3D;

	/**
	 * The Plane3D is used for creating a plane primitive
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		2
	 * @date 		12.01.2006 
	 *
	 * @example To create a plane 100 by 100, with default number of faces,
	 * and the default quality and alignment here is the statement:
	 *
	 * <listing version="3.0">
	 *     var plane:Plane3D = new Plane3D( "thePlane", 100, 100 );
	 *  </listing>
	 * To create the same plane aligned paralell to the zx-plane use:
	 * <listing version="3.0">
	 *     var plane:Plane3D = new Plane3D( "thePlane", 100, 100, 1, 1, Plane3D.XY_ALIGNED );
	 *  </listing>
	 */
	public class Plane3D extends Shape3D implements Primitive3D
	{
		public static const XY_ALIGNED:String = "xy_aligned";
		public static const YZ_ALIGNED:String = "yz_aligned";
		public static const ZX_ALIGNED:String = "zx_aligned";
		//////////////////
		///PRIVATE VARS///
		//////////////////	
		private var _h:Number;
		private var _lg:Number;
		private var _qH:uint;
		private var _qV:uint;
		private var m_sType:String;
		private var _mode : String;
		
		/**
		 * Creates a Plane primitive.
		 * 
		 * <p>The plane is vreated with its center in the origin of the global coordinate system, 
		 * and paralell to one of the global coordinate planes in accordance with the alignment parameter<br/>
		 * The plane is divided in rectangular or triangular polygons</p> 
		 *
		 * @param 	p_nHeight	
		 * @param 	p_nWidth
		 * @param 	p_nQualityH 	Number of segments horizontally
		 * @param	p_nQualityV	Number of segments vertically
		 * @param	p_sType		Alignment of the plane, one of XY_ALIGNED ( default ), YZ_ALIGNED or ZX_ALIGNED
		 * @param 	p_sMode 	One of two available face generation modes: 
		 *    	                  	"tri" generates faces with 3 vertices, 
		 * 				"quad" generates faces with 4 vertices.
		 */
		public function Plane3D(p_sName:String=null, p_nHeight:Number = 100, p_nWidth:Number = 100, p_nQualityH:uint = 1, 
								p_nQualityV:uint=1, p_sType:String=Plane3D.XY_ALIGNED, p_sMode:String=null )
		{
			
			super( p_sName ) ;
			_h = p_nHeight;
			_lg = p_nWidth;
			_qV = p_nQualityV;
			_qH = p_nQualityH;
			_mode = ( p_sMode != PrimitiveMode.TRI && p_sMode != PrimitiveMode.QUAD ) ? PrimitiveMode.TRI : p_sMode;
			m_sType = p_sType;
			geometry = generate() ;
		}

		/**
		 * Generates the geometry for this Shape3D
		 *
		 * @see sandy.core.data.Vertex
		 * @see sandy.core.data.UVCoord
		 * @see sandy.core.data.Polygon
		 */
		public function generate( ...arguments ):Geometry3D
		{
			var l_geometry:Geometry3D = new Geometry3D();
			//Creation of the points
			var i:uint, j:uint;
			var h2:Number = _h/2;
			var l2:Number = _lg/2;
			var pasH:Number = _h/_qV;
			var pasL:Number = _lg/_qH;
			var iH:Number, iL:Number, iTH:Number, iTL:Number;
			
			for( i = 0, iH = -h2, iTH = 0; i <= _qV; iH += pasH, iTH += pasH, i++ )
			{
				for( j=0, iL = -l2, iTL = 0; j <= _qH; iL += pasL, iTL += pasL, j++ )
				{	
					if( m_sType == Plane3D.ZX_ALIGNED )
					{
						l_geometry.setVertex( l_geometry.getNextVertexID(), iL, 0, iH );
					}
					else if( m_sType == Plane3D.YZ_ALIGNED )
					{
						l_geometry.setVertex( l_geometry.getNextVertexID(), 0, iL, iH );
					}
					else
					{
						l_geometry.setVertex( l_geometry.getNextVertexID(), iL, iH, 0 );
					}
					l_geometry.setUVCoords( l_geometry.getNextUVCoordID(), iTH/_h, iTL/_lg );
				}
			}
			
				
			for( i = 0; i < _qV; i++ )
			{
				for( j = 0; j < _qH; j++ )
				{
					//Face creation
					if( _mode == PrimitiveMode.TRI )
					{
						l_geometry.setFaceVertexIds( l_geometry.getNextFaceID(), (i*(_qH+1))+j, (i*(_qH+1))+j+1, (i+1)*(_qH+1)+j );
						l_geometry.setFaceUVCoordsIds( l_geometry.getNextFaceUVCoordID(), (i*(_qH+1))+j, (i*(_qH+1))+j+1, (i+1)*(_qH+1)+j );
						 
						l_geometry.setFaceVertexIds( l_geometry.getNextFaceID(), (i*(_qH+1))+j+1, (i+1)*(_qH+1)+j+1, (i+1)*(_qH+1)+j );
						l_geometry.setFaceUVCoordsIds( l_geometry.getNextFaceUVCoordID(), (i*(_qH+1))+j+1, (i+1)*(_qH+1)+j+1, (i+1)*(_qH+1)+j );
					}
					else if( _mode == PrimitiveMode.QUAD )
					{
						l_geometry.setFaceVertexIds( l_geometry.getNextFaceID(), (i*(_qH+1))+j, (i*(_qH+1))+j+1, (i+1)*(_qH+1)+j+1, (i+1)*(_qH+1)+j );
						l_geometry.setFaceUVCoordsIds( l_geometry.getNextFaceUVCoordID(), (i*(_qH+1))+j, (i*(_qH+1))+j+1, (i+1)*(_qH+1)+j+1, (i+1)*(_qH+1)+j );
					}
				}
			}

			return (l_geometry);
		}
	}

}