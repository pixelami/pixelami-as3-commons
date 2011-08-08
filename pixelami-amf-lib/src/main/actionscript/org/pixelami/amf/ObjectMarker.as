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
	public class ObjectMarker
	{
		/*
		undefined-marker = 0x00 
		*/
		public static const UNDEFINED:int = 0x00;
		
		/*
		null-marker = 0x01
		*/
		public static const NULL:int = 0x01;
		
		/*
		false-marker = 0x02
		*/
		public static const FALSE:int = 0x02;
		
		/*
		true-marker  = 0x03
		*/
		public static const TRUE:int = 0x03;
		
		/*
		integer-marker  = 0x04
		*/
		public static const INTEGER:int = 0x04;
		
		/*
		double-marker = 0x05
		*/
		public static const DOUBLE:int = 0x05;
		
		/*
		string-marker = 0x06
		*/
		public static const STRING:int = 0x06;
		
		/*
		xml-doc-marker = 0x07
		*/
		public static const XMLDOC:int = 0x07;
		
		/*
		date-marker = 0x08
		*/
		public static const DATE:int = 0x08;
		
		/*
		array-marker = 0x09
		*/
		public static const ARRAY:int = 0x09;
		
		/*
		object-marker = 0x0A
		*/
		public static const OBJECT:int = 0x0A;
		
		/*
		xml-marker = 0x0B
		*/
		public static const XML:int = 0x0B;
		
		/*
		byte-array-marker = 0x0C
		*/
		public static const BYTEARRAY:int = 0x0C;
	}
}