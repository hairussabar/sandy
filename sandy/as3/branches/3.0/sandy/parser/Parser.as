package sandy.parser
{
	import sandy.parser.AParser;
	import sandy.parser.ASEParser;
	
	public final class Parser
	{
		public static const ASE:String = "ASE";
		
		public static function create( p_sFileName:String, p_sParserType:String=null ):IParser
		{
			var l_sExt:String,l_iParser:IParser = null;
			if( p_sParserType == null )  l_sExt = (p_sFileName.split('.')).reverse()[0];
			else l_sExt = p_sParserType
			// --
			switch( l_sExt.toUpperCase() )
			{
				case "ASE":
					l_iParser = new ASEParser( p_sFileName );
					break;
				case "OBJ":
					break;
				case "DAE":
					break;
				case "3DS":
					break;
				default:
					break;
			}
			// --
			return l_iParser;
		}
	}
}