////////////////////////////////////////////////////////////////////////////////
//
//  pixelami.com
//  Copyright 2011 Original Authors
//  All Rights Reserved.
//
//  NOTICE: Pixelami permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package org.pixelami.amf
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;

	internal class DescribeTypeCache
	{
		private static var cache:Dictionary = new Dictionary(true);
		
		public static function getDescription(type:Object):XML
		{
			var xml:XML = cache[getQualifiedClassName(type)];
			if(!xml)
			{
				xml = describeType(type);
				cache[getQualifiedClassName(type)] = xml;
			}
			return xml;
		}
	}
}