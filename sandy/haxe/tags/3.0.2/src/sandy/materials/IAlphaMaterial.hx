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

package sandy.materials;

/**
 * Interface for setting and getting alpha on a material.
 * 
 * @author		flexrails
 * @version		3.0
 * @date 		22.03.2008
 **/
interface IAlphaMaterial
{
	/**
	 * Indicates the alpha transparency value of the material. Valid values are 0 (fully transparent) to 1 (fully opaque).
	 */
	private function __setAlpha(p_nValue:Float):Float;

	/**
	 * @private
	 */ 
	public var alpha(__getAlpha,__setAlpha):Float;
	private function __getAlpha():Float;
}

