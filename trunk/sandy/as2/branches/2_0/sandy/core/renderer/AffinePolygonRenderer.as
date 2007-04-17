import sandy.core.face.Polygon;
import sandy.core.renderer.IRenderer;
import sandy.materials.Appearance;
import com.bourre.log.LogChannel;
import com.bourre.log.Logger;
import flash.display.BitmapData;
import flash.geom.Matrix;


/**
 * @author thomaspfeiffer
 */
class sandy.core.renderer.AffinePolygonRenderer implements IRenderer 
{
	public function AffinePolygonRenderer(Void)
	{
		init();
	}
	
	public function init():Void
	{
		m_aPolygon = new Array();
	}
	
	public function addToDisplayList( p_oPolygon:Polygon, p_nDepth:Number ):Void
	{
	    m_aPolygon.push( {polygon: p_oPolygon, depth: p_nDepth } );
	}
	
	public function getDisplayListLength(Void):Number
	{
		return m_aPolygon.length;
	}
	
	public function clear():Void
	{
	    var l_oDisplayElt:MovieClip = null;
	    var i:Number;
	    // --
		for( i=0; l_oDisplayElt = m_aPolygonCopy[i]; i++ )
		{
		   l_oDisplayElt.polygon.container.clear();
		}
	}
		
	public function render():Void 
	{
		// -- sorting with the simple painter algorithm
		m_aPolygon.sortOn( "depth", Array.NUMERIC | Array.DESCENDING );
		// --
		var i:Number;
		var l_oP:Polygon;
		for( i=0; l_oP = Polygon( m_aPolygon[i].polygon ); i++ ) 
		{
			l_oP.container.swapDepths(i);
			renderPolygon( l_oP, l_oP.appearance, l_oP.container );
		}
		// -- copy
		m_aPolygonCopy = m_aPolygon.concat();
	}

	function renderPolygon( p_oPolygon:Polygon, p_oAppearance:Appearance, p_mcContainer:MovieClip ) : Void
	{
		var l_points:Array = p_oPolygon.cvertices;
		var l:Number;
		// --
		p_oAppearance.material.prepare( p_oPolygon );
		// -- We apply the filters on the container. TODO check if this shall be done first or later
		p_mcContainer.filters = p_oAppearance.filters;
		// -- start rendering with passed skin
		if( p_oAppearance.texture )
		{
			p_mcContainer.beginBitmapFill( BitmapData(p_oAppearance.texture), p_oAppearance.material.matrix, Boolean(p_oAppearance.material.repeat), Boolean(p_oAppearance.material.smooth) );
			// --
			if( p_oAppearance.lineAttributes )
				p_mcContainer.lineStyle( p_oAppearance.lineThickness, p_oAppearance.lineColor, p_oAppearance.lineAlpha );
			// --
			p_mcContainer.moveTo( l_points[0].sx, l_points[0].sy );
			// --
			l = l_points.length;
			while( --l > 0 )
			{
				p_mcContainer.lineTo( l_points[(l)].sx, l_points[(l)].sy);
			}
			// --
			p_mcContainer.endFill();
		}
		// -- we draw the last edge
		if( p_oAppearance.lineAttributes )
		{
			p_mcContainer.lineTo( l_points[0].sx, l_points[0].sy );
		}
	}
	
	private var m_aPolygon:Array;
	private var m_aPolygonCopy:Array;
}