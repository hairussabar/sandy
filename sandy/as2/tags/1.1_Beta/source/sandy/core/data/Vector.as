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

/**
* Point in a 4D world but very useful in 3D world too.
* 
* <p>A Point4 has got one more coordinate than the basic Point3D : w. This
* can represent the time coordinate in a 3D world</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @since		0.1
* @version		0.3
* @date 		28.03.2006
*/
class sandy.core.data.Vector
{
	public var x:Number;
	public var y:Number;
	public var z:Number;

	/**
	* <p>Create a new {@code Vector} Instance</p>
	* 
	* @param	px	the x coordinate
	* @param	py	the y coordinate
	* @param	pz	the z coordinate
	*/ 	
	public function Vector(px:Number, py:Number,pz:Number)
	{
		x = px || 0; 
		y = py || 0; 
		z = pz || 0; 
	}
	
	
	/**
	* Get a String represntation of the {@code Vector}.
	* 
	* @return	A String representing the {@code Vector}.
	*/ 	
	public function toString(Void):String
	{
		return "Vector4 : "+x+","+y+","+z;
	}
}

