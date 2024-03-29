///////////////////////////////////////////////////////////
//  Vector.as
//  Macromedia ActionScript Implementation of the Class Vector
//  Generated by Enterprise Architect
//  Created on:      26-VII-2006 13:46:10
//  Original author: Thomas Pfeiffer - kiroukou
///////////////////////////////////////////////////////////

package sandy.core.data
{
	import sandy.core.data.Vertex;
	
	/**
	 * Point in a 4D world but very useful in 3D world too.
	 * <p>A Point4 has got one more coordinate than the basic Point3D : w. This can
	 * represent the time coordinate in a 3D world</p>
	 * @since		0.1
	 * @author Thomas Pfeiffer - kiroukou
	 * @version 0.3
	 * @date 		28.03.2006
	 * @created 26-VII-2006 13:46:10
	 */
	public class Vector
	{
	    public var x: Number;
	    public var y: Number;
	    public var z: Number;

	     /**
	     * <p>Create a new {@code Vector} Instance</p>
	     * 
	     * @param px    the x coordinate
	     * @param py    the y coordinate
	     * @param pz    the z coordinate
	     */
	    public function Vector(px:Number = 0, py:Number = 0, pz:Number = 0)
	    {
	    	x = px; 
			y = py; 
			z = pz; 
	    }
	    
	    public function toVertex():Vertex
	    {
	    	return new Vertex (x,y,z);
	    }
	    /**
	     * Get a String represntation of the {@code Vector}.
	     * @return	A String representing the {@code Vector}.
	     * 
	     * @param Void
	     */
	    public function toString(): String
	    {
	    	/**
			 * @modification Franto here was Vector4 not Vector  ... why?
			 */
	    	return "Vector : "+x+","+y+","+z;
	    }

	   

	}//end Vector

}