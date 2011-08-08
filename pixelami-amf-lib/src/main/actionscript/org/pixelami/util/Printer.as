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
	import flash.utils.ByteArray;

	public class Printer
	{
		public static function prettyPrint(ba:ByteArray):void
		{
			var str:String = "";
			var hex:String = "";
			var ascii:String = "";
			
			for(var i:uint = 0 ; i < ba.length ; i++)
			{
				var n:int = ba[i];
				var char:String = String.fromCharCode(n);
				if(char == "\n") char = "\\";
				if(char == "\r") char = "\\";
				char += " ";
				if(n < 32) char = "? ";
				
				//char = char.length == 1 ? char + " " : char;
				ascii += n > 0 ? char  : '0 ';
				
				var h:String = n.toString(16);
				while(h.length <2) h = '0'+h;
				hex += '0x'+h + "  ";
				if(i % 8 == 7) 
				{
					str += hex + "\t" + ascii + "\n";
					hex = '';
					ascii = '';
				}
			}
			while (hex.length < 48) hex += ' ';
			str += hex + "\t" + ascii;
			trace(str);	
			
		}
		
		public static function int2Char(n:int):String 
		{
			var char:String = String.fromCharCode(n);
			if(char == "\n") char = "\\";
			if(char == "\r") char = "\\";
			char += " ";
			if(n < 32) char = "? ";
			return char;
		}
		
		public static function int2hexstr(n:int):String
		{
			var h:String = n.toString(16);
			while(h.length <2) h = '0'+h;
			return '0x'+h;
		}
		
		public static function hex2ascii(hexstr:String):String
		{
			var asciistr:String = '';
			var i:uint = 0;
			while(i < hexstr.length)
			{
				var h:String = hexstr.slice(i,i+2);
				//trace(h);
				asciistr += String.fromCharCode(parseInt("0x"+h));
				
				i = i+2;
			}
			trace("Utils.hex2ascii = "+asciistr);
			return asciistr
		}
		
		public static function hex2raw(hexstr:String):ByteArray
		{
			var raw:ByteArray = new ByteArray();
			var i:uint = 0;
			while(i < hexstr.length)
			{
				var h:String = hexstr.slice(i,i+2);
				//trace(h);
				raw.writeByte(parseInt("0x"+h));
				
				i = i+2;
			}
			////trace(asciistr);
			return raw;
		}
		
		
		public static function printBits(ba:ByteArray):void
		{
			var cols:uint = 8;
			var str:String = "";
			var bits:String = "";
			var hex:String = "";
			var ascii:String = "";
			
			for(var i:uint = 0 ; i < ba.length ; i++)
			{
				var byte:int = ba[i];
				bits += padLeft(byte.toString(2)) + " ";
				hex += int2hexstr(byte) + " ";
				ascii += int2Char(byte) + " ";
				if(i % cols == (cols-1))
				{
					str += bits + "\t" + hex + "\t" + ascii + "\n" ;
					bits = "";
					hex = "";
					ascii = "";
				}
			}
			
			while (bits.length < cols * 9) bits += ' ';
			while (hex.length < cols * 5) hex += ' ';
			str += bits + "\t" + hex + "\t" + ascii;
			trace(str);	
		}
		
		private static function padLeft(string:String, count:uint=8):String
		{
			while(string.length < count) string = '0'+string;
			return string;
		}
		
		
		public static function decodeU29(bytes:ByteArray):uint
		{
			return 0;
		}
		
		public static function decodeU29S(bytes:ByteArray):uint
		{
			return 0;
		}
		
		public static function getLowBit(byte:int):int
		{
			return byte >> 7;
		}
	}
}