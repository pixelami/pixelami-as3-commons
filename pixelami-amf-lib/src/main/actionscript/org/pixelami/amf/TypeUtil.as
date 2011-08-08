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
			//var record:XML = DescribeTypeCache.getDescription(o);
			var classInfo:XML = DescribeTypeCache.getDescription(o);//record.typeDescription;
			//var classInfo:XML = describeType( a );
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
	}
}


class DescribeTypeCacheRecord
{
	//public function DescribeTypeCacheRecord(){};
	public var typeDescription:XML;
}