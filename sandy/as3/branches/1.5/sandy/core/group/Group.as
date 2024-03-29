///////////////////////////////////////////////////////////
//  Group.as
//  Macromedia ActionScript Implementation of the Class Group
//  Generated by Enterprise Architect
//  Created on:      26-VII-2006 13:46:05
//  Original author: Thomas Pfeiffer - kiroukou
///////////////////////////////////////////////////////////

package sandy.core.group
{
	import sandy.core.group.Node;
	import sandy.core.group.INode;
	/**
	 * Class implementing the Abstract class Node. It's the basic class for all the
	 * classes used to represent the Groups in Sandy. It is used as a node in the tree
	 * scene structure in Sandy, a node without associated transformation in oposition
	 * of TransfromGroup.
	 * @since		1.0
	 * @author Thomas Pfeiffer - kiroukou
	 * @version 1.0
	 * @date 		28.03.2006
	 * @created 26-VII-2006 13:46:05
	 */
	public class Group extends Node implements INode
	{
		/**
		* Constructor of Group class.
		* Group is a concrete node object, and it represents a structure of object.
		* 
		* @param	parent
		*/
		public function Group() 
		{
			super();
		}	
		
		public function render():void
		{
			;
		}
		public function dispose():void
		{
			;
		}
	}//end Group

}