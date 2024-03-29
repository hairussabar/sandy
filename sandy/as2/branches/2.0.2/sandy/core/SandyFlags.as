﻿/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author Thomas PFEIFFER
Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.mozilla.org/MPL/MPL-1.1.html
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# ***** END LICENSE BLOCK ******/

class sandy.core.SandyFlags
{
	
	public static var VERTEX_WORLD:Number = 1 << 1;   
	public static var VERTEX_CAMERA:Number = 1 << 2;  
	public static var VERTEX_PROJECTED:Number = 1 << 3; 
	
	public static var POLYGON_NORMAL_WORLD:Number = 1;
	public static var VERTEX_NORMAL_WORLD:Number = 2;
	//public static var INVERT_MODEL_MATRIX:Number = 4;
	
}