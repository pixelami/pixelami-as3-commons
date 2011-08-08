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

	public class ReferenceTable
	{
		public var objectRefCounter:int = 0;
		public var traitsRefCounter:int = 0;
		public var stringRefCounter:int = 0;
		
		public var traitsTable:Object = {};
		public var stringsTable:Object = {};
		public var objectsTable:Dictionary = new Dictionary(true);
		
		public function ReferenceTable()
		{
		}
	}
}