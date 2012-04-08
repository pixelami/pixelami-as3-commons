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

package org.pixelami.util
{
	public class TypedAttribute implements IAttribute
	{
		public static const SIMPLE_TYPES:Array = ["String","Number","int","uint","Boolean"]
		
		private var _name:String;
		private var _value:*;
		private var _type:String;
		
		
		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get value():*
		{
			return _value;
		}

		public function set value(value:*):void
		{
			_value = value;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		
		public function TypedAttribute(name:String = "",type:String = "",value:* = null)
		{
			_name = name;
			_value = value;
			_type = type;
		}
		
		public function clone():TypedAttribute
		{
			return new TypedAttribute(_name,_value,_type);
		}
		
		
		public function isComplexType():Boolean
		{
			return SIMPLE_TYPES.indexOf(type) == -1
		}
	}
}