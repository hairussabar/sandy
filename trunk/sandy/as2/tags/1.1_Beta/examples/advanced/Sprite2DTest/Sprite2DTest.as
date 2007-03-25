
import sandy.core.group.*;
import sandy.view.*;
import sandy.core.*;
import sandy.skin.*;
import sandy.util.BitmapUtil;
import sandy.core.transform.*;
import flash.display.BitmapData;
import com.bourre.events.BasicEvent;

/**
* @mtasc -main Sprite2DTest -swf Sprite2DTest.swf -header 300:300:120:FFFFFF -version 8 -wimp
*/
class Sprite2DTest 
{
	private var _mc : MovieClip;
	private var _mcLoader:MovieClipLoader;
	private var _bmp:BitmapData;
	private var _fps:Number;
	private var _t:Number;
	
	private static var NUM_ELEMENTS:Number = 100;
	
	public function Sprite2DTest( mc:MovieClip ) 
	{
		_mc = mc;
		_mcLoader = new MovieClipLoader();
		_mcLoader.addListener(this);
		_mc.createTextField( 'fps', 10000, 0, 20, 50, 20 );
		_t  = getTimer();
		_fps = 0;
		World3D.getInstance().addEventListener( World3D.onRenderEVENT, this, __refreshFps );
		if( mc.texture instanceof MovieClip )	__start( _mc );
		else									loadClip('arbre2.gif');
		
	}
	
	private function __refreshFps ():Void
	{
		if( getTimer() > _t + 1000 )
		{
			_mc.fps.text = _fps+' ips';
			_fps = 0;
			_t = getTimer();
		}
		else _fps++;
		__onRender();
	}
	
	public static function main( mc:MovieClip ) : Void 
	{
		if( !mc ) mc = _root;
		var c:Sprite2DTest = new Sprite2DTest( mc );
	}
	
	// this method is invoked when the mcLoader has loaded the clip
	public function onLoadInit(target:MovieClip):Void
	{
		__start( target );
	}
 	
	private function __start ( mc:MovieClip ):Void
	{
		var w:World3D = World3D.getInstance();
		w.setRootGroup( __createScene( mc ) );
		__createCams();
		//w.addEventListener( World3D.onRenderEVENT, this, __onRender );
		w.render();
	}

	private function __createCams ( Void ):Void
	{
		var mc:MovieClip = _mc.createEmptyMovieClip( 'screen', 1 );
		var screen:ClipScreen = new ClipScreen( mc, 300, 300 );
		var cam:Camera3D = new Camera3D( 700, screen );
		World3D.getInstance().addCamera( cam );
	}

	private function __onRender ( e:BasicEvent ):Void
	{
		var cam:Camera3D = World3D.getInstance ().getCamera();
		// rotation around the global vertical axis
		switch( true )
		{
			case Key.isDown (Key.RIGHT)	: cam.rotateY ( 3 ); 		break;
			case Key.isDown (Key.LEFT)	: cam.rotateY ( -3 ); 		break;
			case Key.isDown (Key.UP)	: cam.moveForward ( 10 ); 	break;
			case Key.isDown (Key.DOWN)	: cam.moveForward ( -10 ); 	break;
			//case Key.isDown (Key.SHIFT)	: cam.tilt ( 1 ); 		break;
			//case Key.isDown (Key.CONTROL) : cam.tilt ( -1 ); 		break;
		}
	}
	
	private function loadClip( im:String )
	{
		var pathName:String = im;
		// this MC will never appear on screen:
		var loaderMC:MovieClip = _mc.createEmptyMovieClip( 'texture_mc', _mc.getNextHighestDepth() );
		_mcLoader.loadClip( pathName, loaderMC );
	}

	private function __createScene ( mc:MovieClip ):Group
	{
		mc._visible = false;
		var b:BitmapData = BitmapUtil.movieToBitmap( mc, true );
		var skin:TextureSkin = new TextureSkin( b );
		//var skin:TextureSkin = new MovieSkin( mc );
		var bg:Group 		 = new Group();
		for( var i:Number = 0; i < Sprite2DTest.NUM_ELEMENTS; i++ )
		{
			var s:Sprite2D = new Sprite2D();
			s.setSkin( skin );
			var tgT:TransformGroup = new TransformGroup();
			var trans:Transform3D = new Transform3D();
			trans.translate( Math.random() * 1000 - 500, 0, Math.random() * 2000 - 1000 );
			tgT.setTransform( trans );
			tgT.addChild( s );
			bg.addChild( tgT );
		}
		return bg;
	}
}
