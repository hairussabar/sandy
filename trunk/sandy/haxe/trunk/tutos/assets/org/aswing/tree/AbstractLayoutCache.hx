package org.aswing.tree;

extern class AbstractLayoutCache implements RowMapper {
	function new() : Void;
	function getBounds(path : TreePath, placeIn : org.aswing.geom.IntRectangle) : org.aswing.geom.IntRectangle;
	function getExpandedState(path : TreePath) : Bool;
	function getModel() : TreeModel;
	function getNodeDimensions() : NodeDimensions;
	function getPathClosestTo(x : Int, y : Int) : TreePath;
	function getPathForRow(row : Int) : TreePath;
	function getPreferredHeight() : Int;
	function getPreferredWidth(bounds : org.aswing.geom.IntRectangle) : Int;
	function getRowContainingYLocation(location : Int) : Int;
	function getRowCount() : Int;
	function getRowForPath(path : TreePath) : Int;
	function getRowHeight() : Int;
	function getRowsForPaths(paths : Array<Dynamic>) : Array<Dynamic>;
	function getSelectionModel() : TreeSelectionModel;
	function getVisibleChildCount(path : TreePath) : Int;
	function getVisiblePathsFrom(path : TreePath, totalCount : Int) : Array<Dynamic>;
	function invalidatePathBounds(path : TreePath) : Void;
	function invalidateSizes() : Void;
	function isExpanded(path : TreePath) : Bool;
	function isRootVisible() : Bool;
	function setExpandedState(path : TreePath, isExpanded : Bool) : Void;
	function setModel(newModel : TreeModel) : Void;
	function setNodeDimensions(nd : NodeDimensions) : Void;
	function setRootVisible(rootVisible : Bool) : Void;
	function setRowHeight(rowHeight : Int) : Void;
	function setSelectionModel(newLSM : TreeSelectionModel) : Void;
	function treeNodesChanged(e : org.aswing.event.TreeModelEvent) : Void;
	function treeNodesInserted(e : org.aswing.event.TreeModelEvent) : Void;
	function treeNodesRemoved(e : org.aswing.event.TreeModelEvent) : Void;
	function treeStructureChanged(e : org.aswing.event.TreeModelEvent) : Void;
	private var nodeDimensions : NodeDimensions;
	private var rootVisible : Bool;
	private var treeModel : TreeModel;
	private var treeSelectionModel : TreeSelectionModel;
	private function countNodeDimensions(value : Dynamic, row : Int, depth : Int, expanded : Bool, placeIn : org.aswing.geom.IntRectangle) : org.aswing.geom.IntRectangle;
}