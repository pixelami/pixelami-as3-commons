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

	public class TypeUtil
	{
		/**
		 * Taken from com.adobe.serialization.json
		 * This will return accessors (getter/setter) and variables
		 * It will not return non writable properties or properties that
		 * have been marked with [Transient] metadata tag
		 */
		
		public static function getPropertiesAndAccessors(o:Object):Array
		{
			var classInfo:XML = getDescription(o);
			var a:Array = [];
			
			for each ( var v:XML in classInfo..*.( 
				name() == "variable"
				||
				( 
					name() == "accessor"
					// Issue #116 - Make sure accessors are readable
					&& attribute( "access" ).charAt( 0 ) == "r" ) 
			) )
			{
				// Issue #110 - If [Transient] metadata exists, then we should skip
				if ( v.metadata && v.metadata.( @name == "Transient" ).length() > 0 )
				{
					continue;
				}
				
				a.push(v.@name);
			}
			
			return a;
		}
		
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


class DescribeTypeCacheRecord
{
	//public function DescribeTypeCacheRecord(){};
	public var typeDescription:XML;
}