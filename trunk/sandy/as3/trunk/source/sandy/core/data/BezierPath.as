///////////////////////////////////////////////////////////
//  BezierPath.as
//  Macromedia ActionScript Implementation of the Class BezierPath
//  Generated by Enterprise Architect
//  Created on:      26-VII-2006 13:46:04
//  Original author: Thomas Pfeiffer - kiroukou
///////////////////////////////////////////////////////////

package sandy.core.data
{
	import sandy.core.data.Vector;
	import sandy.util.BezierUtil;
	
	/**
	 * A 3D path interpolated with Bezier equations
	 * <p>A Bezier path is basically an array of 3D points, but the path is
	 * interpolated thanks to Bezier equations, allowing some nice movements</p>
	 * @since		1.0
	 * @author Thomas Pfeiffer - kiroukou
	 * @version 1.0
	 * @date 		27.04.2006
	 * @created 26-VII-2006 13:46:04
	 */
	public final class BezierPath
	{
	    /**
	     * properties used to store transformed coordinates in the local frame of the
	     * object
	     */
	    private var _aContainer: Array;
	    /**
	     * Array of segments
	     */
	    private var _aSegments: Array;
	    /**
	     * Boolean set to true is the path has to be closed, false otherwise. default is
	     * false
	     */
	    private var _bBoucle: Boolean;
	    /**
	     * Boolean keeping the state the the path, compiled or not
	     */
	    private var _bCompiled: Boolean;
	    /**
	     * current segment id
	     */
	    private var _nCrtSegment: Number;
	    /**
	     * The number of points of the path
	     */
	    private var _nNbPoints: Number;
	    /**
	     * The number of segments of the path
	     */
	    private var _nNbSegments: Number;
	    private var _nRatio: Number;

	    /**
	     * Create a new {@code BezierPath} Instance.
	     */
	    public function BezierPath()
	    {
	    	_aContainer = new Array();
			_aSegments = new Array();
			_nCrtSegment = 0;
			_bBoucle = false;
			_bCompiled = false;
	    }
	    
	    /**
	     * Add a point to the path. WARNING : You can't add a point to the path once it
	     * has been compiled.
	     * @return 	Boolean true if operation succeed, false otherwise.
	     * 
	     * @param x    Number
	     * @param y    Number
	     * @param z    Number
	     */
	    public function addPoint(x:Number, y:Number, z:Number): Boolean
	    {
	    	if( _bCompiled ) 
			{
				return false;
			}
			else
			{
				_aContainer.push( new Vector( x, y, z ) );
				return true;
			}
	    }

	    /**
	     * Computes all the control points. Must be called before being used by Sandy's
	     * engine. Should be called once tha last point of the path has been added.
	     * 
	     * @param Void    Void
	     */
	    public function compile():void
	    {
	    	_nNbPoints = _aContainer.length;
			if( _nNbPoints%3 != 2)
			{
				trace('sandy.core.data.BezierPath ERROR: Number of points incompatible');
				return;
			}
			_bCompiled = true;
			_nNbSegments = 0;
			var a:Vector, b:Vector, c:Vector;
			for (var i:Number = 0; i <= _nNbPoints-2; i+=2 )
			{
				a = _aContainer[i]; 
				b = _aContainer[i+1];
				c = _aContainer[i+2];
				_aSegments.push( [ a, b, c ] );
			}
			if( _bBoucle )
			{
				_aSegments.push([ 	_aContainer[ _nNbPoints ], 
									BezierUtil.getQuadControlPoints(_aContainer[ _nNbPoints ],_aContainer[ 0 ],_aContainer[ 1 ]), 
									_aContainer[ 0 ] 
								]);
			}
			// -- 
			_nNbSegments = _aSegments.length;
			_nRatio = 1 / _nNbSegments;
	    }

	    /**
	     * returns the number of segments;
	     * @return Number the number of segments
	     * 
	     * @param Void
	     */
	    public function getNumberOfSegments(): Number
	    {
	    	return _nNbSegments;
	    }

	    /**
	     * Returns the position in the 3D space at a specific percentage. You can imagine
	     * the whole path length as the 1.0 value (100%). Now if you need the position
	     * when you are at only 10% of the whole path you just have to pass 0.1 in
	     * argument, and the returned value is the position on that percentage of the
	     * whole path.
	     * @return	Vector The 3D position on the path at the current percentage.
	     * 
	     * @param p    Number A percentage between [0-1]
	     */
	    public function getPosition(p:Number): Vector
	    {
	    	var id:Number = Math.floor(p/_nRatio);
			if( id == _nNbSegments )
			{
				id --;
				p = 1.0;
			}
			var seg:Array = getSegment( id );
			return BezierUtil.getPointsOnQuadCurve( (p-id*_nRatio)/_nRatio, seg[0], seg[1], seg[2] );
	    }

	    /**
	     * Returns the segment that fits to the percentage number passed in arguments. You
	     * can imagine the whole path length as the 1.0 value (100%). Now if you need the
	     * segment when you are at only 10% of the whole path you just have to pass 0.1 in
	     * argument, and the returned array contain the bezierCurve points [startPoint,
	     * controlPoint, endPoint]
	     * @return	Array array containing the segment's bezierCurve points [startPoint,
	     * controlPoint, endPoint]
	     * 
	     * @param pnId
	     */
	    public function getSegment(pnId:Number): Array
	    {
	    	if( pnId >= 0 && pnId < _nNbSegments )
			{
				return _aSegments[ pnId ];
			}
			else
			{
				return null;
			}
	    }

	    /**
	     * Get a String represntation of the {@code BezierPath}.
	     * @return	A String representing the {@code BezierPath}.
	     * 
	     * @param Void
	     */
	    public function toString(): String
	    {
	    	return "sandy.core.data.BezierPath";
	    }

	}//end BezierPath

}