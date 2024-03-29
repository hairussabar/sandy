﻿/*
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

import com.bourre.events.EventBroadcaster;
import com.bourre.events.EventType;
import com.bourre.commands.Delegate;

import com.bourre.data.libs.GraphicLib;
import com.bourre.data.libs.GraphicLibLocator;
import com.bourre.data.libs.LibEvent;
import com.bourre.data.libs.LibStack;

import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Shape3D;
import sandy.parser.IParser;
import sandy.parser.ParserEvent;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.*;
import sandy.util.BitmapUtil;

/**
 * ABSTRACT CLASS - super class for all parser objects.
 *
 * <p>This class should not be directly instatiated, but sub classed.<br/>
 * The AParser class is responsible for creating the root Group, loading files
 * and handling the corresponding events.</p>
 *
 * @author		Thomas Pfeiffer - kiroukou
 * @author		(porting) Floris - xdevltd
 * @since		1.0
 * @version		2.0.2
 * @date 		26.07.2007
 */
 
class sandy.parser.AParser extends MovieClip implements IParser
{
		
	/**
	 * @private
	 */
	private var m_oGroup:Group;
		
	/**
	 * @private
	 */
	private var m_oFile:XML;
						
	/**
	 * @private
	 */
	private var m_nScale:Number;
		
	/**
	 * @private
	 */
	private var m_oStandardAppearance:Appearance;

	private var m_sUrl:String;

	private static var _oEB:EventBroadcaster = new EventBroadcaster( AParser );
	
	/**
	 * Add a listener for a specific event.
	 *
	 * @param  t	EventType The type of event we want to register
	 * @param  o	The object listener
	 */
	public  function addEventListener( t:EventType, o ) : Void
	{
		_oEB.addEventListener.apply( _oEB, arguments );
	}
	
	/**
	 * Remove a listener for a specific event.
	 *
	 * @param  e 	String The type of event we want to register
	 * @param  oL 	The object listener
	 */
	public  function removeEventListener( e:EventType, oL ) : Void
	{
		_oEB.removeEventListener( e, oL );
	}
	
	/**
	 * Creates a parser object. Creates a root Group, default appearance
	 * and sets up an URLLoader.
	 *
	 * @param p_sFile			  Must be either a text string containing the location
	 * 							  to a file or an embedded object.
	 * @param p_nScale			  The scale amount.
	 * @param p_sTextureExtension Overrides texture extension.
	 */
	public function AParser( p_sFile, p_nScale:Number, p_sTextureExtension:String )
	{
		super( this );
		m_oGroup = new Group( 'parser' );
		m_nScale = p_nScale||1;
		m_sTextureExtension = p_sTextureExtension;
		if( typeof( p_sFile ) == "string" )
		{
			m_sUrl = p_sFile;
			m_oFile = new XML();

			// -- assume that textures are in same folder with model itself
			if( m_sUrl.indexOf( '/' ) > m_sUrl.indexOf( '\\' ) )
				RELATIVE_TEXTURE_PATH = m_sUrl.substring( 0, m_sUrl.lastIndexOf( '/' ) );
			else
				RELATIVE_TEXTURE_PATH = m_sUrl.substring( 0, m_sUrl.lastIndexOf( '\\' ) );
		}
		else
		{
			m_oFile = p_sFile;
		}

		standardAppearance = new Appearance( new ColorMaterial( 0xFF, 100, new MaterialAttributes( new LineAttributes() ) ) );
	}

	/**
	 * Set the standard appearance for all the parsed objects.
	 *
	 * @param p_oAppearance		The standard appearance.
	 */
	public function set standardAppearance( p_oAppearance:Appearance ) : Void
	{
		m_oStandardAppearance = p_oAppearance;
	}

	/**
	 * This method is called when an I/O error occurs.
	 *
	 * @param p_nHttpStatus		The error event.
	 */
	private function _io_error( p_nHttpStatus:Number ) : Void
	{
		if( p_nHttpStatus < 200 || p_nHttpStatus > 299 ) 
		{
			_oEB.dispatchEvent( new ParserEvent( ParserEvent.FAIL ) );
		}
	}

	/**
	 * @private
	 *
	 * This method is called when all files are loaded and initialized.
	 *
	 * @param s		Boolean: loaded succesfully.
	 */
	private function parseData( s:Boolean ) : Void
	{
		if( !m_oFile ) _oEB.dispatchEvent( new ParserEvent( ParserEvent.FAIL ) );   
	}
		
	/**
	 * @private
	 */
	private function dispatchInitEvent() : Void
	{
		m_oQueue = new LibStack();
		var l_oContainer:MovieClip = this.createEmptyMovieClip( "texture", this.getNextHighestDepth() );
		var l_oGraphicLib:GraphicLib = new GraphicLib( l_oContainer, 0, false );
		
		// -- load textures, if any
		if( m_aTextures != null )
		{
			for( var i:Number = 0; i < m_aTextures.length; i++ ) 
			{
				m_oQueue.enqueue( l_oGraphicLib, i.toString(), RELATIVE_TEXTURE_PATH + "/" + m_aTextures[ i ] );
			}
			m_oQueue.addEventListener( LibStack.onLoadCompleteEVENT, this, onTexturesloadComplete );
			m_oQueue.load();
		}
		else 
		{
			var l_eOnInit:ParserEvent = new ParserEvent( ParserEvent.INIT );
			l_eOnInit.group = m_oGroup;
			_oEB.dispatchEvent( l_eOnInit );
		}
	}

	private function onTexturesloadComplete() : Void
	{
		for( var i:Number = 0; i < m_aShapes.length; i++ )
		{
			// -- set successfully loaded materials
			var l_oGL:GraphicLib;
			if( ( l_oGL = GraphicLibLocator.getInstance().getGraphicLib( i.toString() ) ) ) 
			{				
				var shapes:Array = m_aShapes[ i.toString() ]; 
				var mat:Appearance = new Appearance( new BitmapMaterial( BitmapUtil.movieToBitmap( l_oGL.getContent(), true ) ) );        
				for( var j:Number = 0; j < shapes.length; j++ ) 
				{       
					// whatever is in m_aShapes must have appearance property or be dynamic class        
					Object( shapes[ j ] ).appearance = mat;
				} 
			}
		}

		m_oQueue.removeEventListener( LibStack.onLoadCompleteEVENT, onTexturesloadComplete );

		// -- this is called even if there were errors loading textures... perfect!
		m_aShapes = m_aTextures = null; dispatchInitEvent();
	}

	/**
	 * @private used internally to load textures
	 */
	private function applyTextureToShape( shape:Object, texture:String )      
	{      
		var texName:String = changeExt( texture );      
		var texId:Number = -1;        
	
		if( m_aTextures == null )
		{        
			// there was no textures enqueued so far        
			m_aTextures = []; m_aShapes = [];        
		}
		else
		{        
			// look up texture, maybe we have it enqueued        
			texId = m_aTextures.indexOf( texName );      
		}
		
		if( texId < 0 ) 
		{
			// this texture is not enqueued yet
			m_aTextures.push( texName );        
			m_aShapes.push( [ shape ] );        
		}
		else
		{        
			// this texture is enqueued, just add shape to the list        
			m_aShapes[ texId ].push( shape );        
		} 
 	}      
		
	/**
	 * @private Collada parser already loads textures on its own, so it needs this private
	 */
	private function changeExt( s:String ) : String
	{
		if( m_sTextureExtension != null )
		{
			var tmp:Array = s.split( "." );
			if( tmp.length > 1 )
			{
				tmp[ tmp.length - 1 ] = m_sTextureExtension;
				s = tmp.join( "." );
			}
			else 
			{
				// leave as is?
				s += "." + m_sTextureExtension;
			}
		}
		return s;
	}

	private var m_sTextureExtension:String;
	private var m_aShapes:Array;
	private var m_aTextures:Array;
	private var m_oQueue:LibStack;
	
	/**   
	 * Default path for images.   
	 */   
	public var RELATIVE_TEXTURE_PATH:String = "."; 
	
    /**
     * Load the file that needs to be parsed. When done, call the parseData method.
     */
    public function parse() : Void
	{
		if( typeof( m_sUrl ) == "string" )
		{
			m_oFile = new XML();
			// Events and their functions
			m_oFile.onLoad = Delegate.create( this, parseData );
			m_oFile.onHTTPStatus = Delegate.create( this, _io_error ); 
			// Start loading
			m_oFile.load( m_sUrl );
		}
		else
		{
			parseData();
		}
	}
	
}