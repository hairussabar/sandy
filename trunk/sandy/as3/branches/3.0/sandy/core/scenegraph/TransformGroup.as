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
package sandy.core.scenegraph 
{
	import sandy.core.data.Matrix4;
	import sandy.core.scenegraph.ATransformable;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.ITransformable;
	import sandy.core.scenegraph.Node;
	import sandy.math.VectorMath;
	import sandy.view.CullingState;
	import sandy.view.Frustum;
	
	/**
	* @author		Thomas Pfeiffer - kiroukou
	* @version		1.0
	* @date 		16.05.2006
	**/
	public class TransformGroup extends ATransformable implements ITransformable
	{
		/**
		* Create a new TransformGroup.
		* This class is one of the most important because it represents a node in the tree scene representation in Sandy.
		* It has a matrix which is in fact its Transform3D property matrix.
		*/ 	
		public function TransformGroup( p_sName:String="" )
		{
			super( p_sName );
		}
		
		
		/**
		 * This method goal is to update the node. For node's with transformation, this method shall
		 * update the transformation taking into account the matrix cache system.
		 */
		public override function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			// Shall be called first
			updateTransform();
			//
			super.update( p_oModelMatrix, p_bChanged );
		}
	
		
		/**
		 * This method test the current node on the frustum to get its visibility.
		 * If the node and its children aren't in the frustum, the node is set to cull
		 * and it would not be displayed.
		 * This method is also updating the bounding volumes to process the more accurate culling system possible.
		 * First the bounding sphere are updated, and if intersecting, the bounding box are updated to perform a more
		 * precise culling.
		 * [MANDATORY] The update method must be called first!
		 */
		public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			// TODO
			// Parse the children, take their bounding volume and merge it with the current node recurssively. 
			// After that call the super cull method to get the correct cull value.		
			changed = p_bChanged || changed;
			var l_oNode:Node;
			for each( l_oNode in _aChilds )
			    l_oNode.cull( p_oFrustum, p_oViewMatrix, changed || l_oNode.changed );
			// --
			super.cull( p_oFrustum, p_oViewMatrix, changed );
		}
		
		public override function render( p_oCamera:Camera3D ):void
		{
			var l_oNode:Node;
			for each( l_oNode in _aChilds )
			{
			    if( l_oNode.culled != Frustum.OUTSIDE )
			    	l_oNode.render( p_oCamera );
			    // --
			    l_oNode.changed = false; // default value is set to not changed.
			    l_oNode.culled = CullingState.INSIDE; // Default value is inside.
			}
		}
		
	 	/**
		 * This method shall be called to update the transform matrix of the current object/node
		 * before being rendered.
		 */
		public function updateTransform():void
		{
			if( changed )
			{
				var mt:Matrix4 = m_tmpMt;
				mt.n11 = _vSide.x * _oScale.x; 
				mt.n12 = _vUp.x; 
				mt.n13 = _vOut.x; 
				mt.n14 = _p.x;
				
				mt.n21 = _vSide.y; 
				mt.n22 = _vUp.y * _oScale.y; 
				mt.n23 = _vOut.y; 
				mt.n24 = _p.y;
				
				mt.n31 = _vSide.z; 
				mt.n32 = _vUp.z; 
				mt.n33 = _vOut.z * _oScale.z;  
				mt.n34 = _p.z;
				
				transform.matrix = mt;
			}
		}
			
		/**
		* Get a String representation of the {@code TransformGroup}.
		* 
		* @return	A String representing the {@code TransformGroup}.
		*/ 
		public override function toString():String
		{
			return "sandy.core.scenegraph.TransformGroup";
		}
	}
}
