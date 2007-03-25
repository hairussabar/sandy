///////////////////////////////////////////////////////////
//  Node.as
//  Macromedia ActionScript Implementation of the Class Node
//  Generated by Enterprise Architect
//  Created on:      26-VII-2006 13:46:06
//  Original author: Thomas Pfeiffer - kiroukou
///////////////////////////////////////////////////////////
package sandy.core.group
{
	import sandy.core.World3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * ABSTRACT CLASS
	 * <p> This class is the basis of all the group and Leaf one. It allows all the
	 * basic operations you might want to do about trees node.
	 * </p>
	 * @author 	Thomas Pfeiffer - kiroukou
	 * @version 1.0
	 * @date 	05.08.2006
	 * @created 26-VII-2006 13:46:06
	 */
	public class Node extends EventDispatcher
	{
	    /**
	     * Add a new child to this group. a basicGroup can have several childs, and when
	     * you add a child to a group, the child is automatically conencted to it's parent
	     * thanks to its parent property.
	     * 
	     * @param child    child
	     */
	    public function addChild(child:Node):void
	    {
	    	child.setParent( this );
			setModified( true );
			_aChilds.push( child );
	    }

	    /**
	     * Delete all the childs of this node, and also the datas it is actually storing.
	     * Do a recurssive call to child's destroy method.
	     * @param [OPTIONAL]update Boolean if set to true (default value) the world 3D
	     * will be automatically updated, if set to false it will not The interest of this
	     * paramater is that it allows you to update the World3D only once during your
	     * destroy/remove call!
	     * 
	     * @param update
	     */
	    public function destroy():void
	    {
	    	// the unlink this node to his parent
			if( hasParent() ) _parent.removeChild( this );
			// should we kill all the childs, or just make them childs of current node parent ?
			var l:Number = _aChilds.length;
			while( --l > -1 )
			{
				_aChilds[l].destroy();
				delete _aChilds[l];	
			}
			_parent = null;
	    }

	    /**
	     * Returns the child node at the specific index.
	     * @return 	Node The desired Node
	     * 
	     * @param index    Number The ID of the child you want to get
	     */
	    public final function getChild(index:uint):Node
	    {
	    	if( index >= _aChilds.length )
	    	{
	    		throw new Error( "Can't access a child to this index" );
	    		return null;
	    	}
	    	else
	    	{
	    		return _aChilds[ index ];
	    	}
	    }

	    /**
	     * Returns all the childs of the current group in an array
	     * @return Array The array containing all the childs node of this group
	     * 
	     * @param Void
	     */
	    public final function getChildList():Array
	    {
	    	return _aChilds;
	    }

	    /**
	     * Retuns the unique ID Number that represents the node. This value is very
	     * usefull to retrieve a specific Node. This method is FINAL, IT MUST NOT BE
	     * OVERLOADED.
	     * @return	Number the node ID.
	     * 
	     * @param Void
	     */
	    public final function getId():uint
	    {
	    	return _id;
	    }

	    /**
	     * Returns the parent node reference
	     * @return Node The parent node reference, which is null if no parents (for
	     * exemple for a root object).
	     * 
	     * @param Void
	     */
	    public final function getParent():Node
	    {
	    	return _parent;
	    }

	    /**
	     * Allows the user to know if the current node have a parent or not.
	     * @return Boolean. True is the node has a parent, False otherwise
	     * 
	     * @param Void
	     */
	    public final function hasParent():Boolean
	    {
	    	return (null != _parent);
	    }

	    /**
	     * Allows you to know if this node has been modified (true value) or not (false
	     * value). Mainly usefull for the cache system. After having called this method,
	     * the modified private property is set to false!
	     * @return	Boolean Value specifying the statut of the node. A true value means the
	     * node has been modified, it it should be rendered again
	     * 
	     * @param Void
	     */
	    public function isModified():Boolean
	    {
	    	return _modified;
	    }

	    /**
	     * Say is the node is the parent of the current node.
	     * @return Boolean  True is the node in argument if the father of the current one,
	     * false otherwise.
	     * 
	     * @param n    The Node you are going to test the patternity
	     */
	    public final function isParent( n:Node ):Boolean
	    {
	    	return (_parent == n && n != null);
	    }

	    /**
	     * / PRIVATE PART
	     * @param p_parent
	     */
	    public function Node()
	    {
		    super( this );
			_parent = null;
			_aChilds = [];
			_id = Node._ID_++;
			setModified( true );
	    }

	    /**
	     * Remove the current node on the tree. It makes current node children the
	     * children of the current parent node.
	     */
	    public final function remove():void
	    {
			var l:Number = _aChilds.length;
			// first we remove this node as a child of its parent
			// we do not update rigth now, but a little bit later ;)
			_parent.removeChild( this );
			// now we make current node children the current parent's node children
			while( --l > -1 )
			{
				_parent.addChild( _aChilds[l] );
			}
			_parent = null;
			setModified( true );
	    }

	    /**
	     * Remove the child given in arguments. Returns true if the node has been removed,
	     * and false otherwise. All the children of the node you want to remove are lost.
	     * The link between them and the rest of the tree is broken. They will not be
	     * rendered anymore! But the object itself and his children are still in memory!
	     * If you want to free them completely, use child.destroy();
	     * @param [OPTIONAL]update Boolean if set to true (default value) the world 3D
	     * will be automatically updated, if set to false it will not The interesst of
	     * this paramater is that it allows you to update the World3D only once during
	     * your last remove/destroy call!
	     * @return Boolean True if the node has been removed from the list, false
	     * otherwise.
	     * @param child    Node The node you want to remove.
	     */
	    public function removeChild(child:Node):Boolean
	    {
			if( !child.isParent( this ) ) return false;
			var found:Boolean = false;
			// --
			for( var i:Number = 0; i < _aChilds.length && !found; i++ )
			{
				if( _aChilds[i] == child )
				{
					_aChilds.splice( i, 1 );
					setModified( true );
					found = true;
				}
			}
			return found;
	    }
	    
	    /**
	     * Set the parent of a node
	     * @param	Void
	     * @return	Boolean false is nothing has been donz, true if the operation succeded
	     * @param n
	     */
	    public function setParent(n:Node):Boolean
	    {
		    if( null == n )
			{
				return false;
			}
			else
			{
				_parent = n;
				setModified( true );
				return true;
			}
	    }
		
		/**
		* Allows you to set the modified property of the node.
		* @param b Boolean true means the node is modified, and false the opposite.
		*/
		public function setModified( b:Boolean ):void
		{
			_modified = b;
		}	
		
		static private var _ID_:uint = 0;
	    
	    private var _id:uint;
	    private var _parent:Node;
	    		    
	    protected var _aChilds:Array;
	    protected var _modified:Boolean;
	}//end Node
}