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
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	import mx.rpc.events.HeaderEvent;
	
	/**
	 * Variable Length Unsigned 29-bit Integer Encoding
	 * <p>AMF 3 makes use of a special compact format for writing integers to reduce the number of bytes required for encoding. 
	 * <p>As with a normal 32-bit integer, up to 4 bytes are required to hold the value however the high bit of the first 3 bytes are used as flags to determine whether the next byte is part of the integer. 
	 * With up to 3 bits of the 32 bits being used as flags, only 29 significant bits remain for encoding an integer. This means the largest unsigned integer value that can be represented is 2 ^ (29 - 1).
	 * <p>
	 * <table>
	 * <th>(hex)</th><th>(binary)</th>
	 * <tr><td>0x00000000 - 0x0000007F</td><td>0xxxxxxx</td></tr>
	 * <tr><td>0x00000080 - 0x00003FFF</td><td>1xxxxxxx 0xxxxxxx</td></tr>
	 * <tr><td>0x00004000 - 0x001FFFFF</td><td>1xxxxxxx 1xxxxxxx 0xxxxxxx</td></tr>
	 * <tr><td>0x00200000 - 0x3FFFFFFF</td><td>1xxxxxxx 1xxxxxxx 1xxxxxxx xxxxxxxx</td></tr>
	 * <tr><td>0x40000000 - 0xFFFFFFFF</td><td>throw range exception</td></tr>
	 * </table>
	 * <p>In ABNF syntax, the variable length unsigned 29-bit integer type is described as follows:
	 * <br>
	 * <strong>
	 * <br>U29 = U29-1 | U29-2 | U29-3 | U29-4
	 * <br>U29-1 = %x00-7F
	 * <br>U29-2 = %x80-FF %x00-7F
	 * <br>U29-3 = %x80-FF %x80-FF %x00-7F
	 * <br>U29-4 = %x80-FF %x80-FF %x80-FF %x00-FF
	 * </strong>
	 */
	public class U29
	{
		public var bytes:ByteArray;
		private var position:int;
		private var flags:Array = [];
		private var bitString:String;
		
		
		public function U29(...args)
		{
			var byteStrings:Array = [];
			bytes = new ByteArray();
			
			if(args.length > 0)
			{
				var arg:int = args.pop();
				bitString = arg.toString(2);
				
				while(args.length > 0)
				{
					arg = args.pop();
					bitString += String(arg);
				}
				//trace("bitString",bitString);
				// pad bitString so that its length is a multiple of 7
				var rem:int = bitString.length % 7;
				if(rem > 0)
				{
				
					for(var i:uint = 0; i < 7 - rem; i++)
					{
						bitString = "0"+bitString;
					}
				}
				//trace("bitString",bitString);
				//trace("bitString.length",bitString.length);
				// split into chunks of length 7
				var m:int = bitString.length / 7;
				for(i = 0; i < m; i++)
				{
					var startIndex:int = i * 7;
					var endIndex:int = ((i+1) * 7);
					byteStrings.push(bitString.slice(startIndex,endIndex)); 
				}
				//trace("byteStrings",byteStrings);
				
				
				// add the u29 byte markers to the byteStrings.
				for(i = 0;i < byteStrings.length; i++)
				{
					var byteString:String = byteStrings[i];
					
					if(i == byteStrings.length - 1)
					{
						byteStrings[i] = "0"+byteString;
					}
					else
					{
						byteStrings[i] = "1"+byteString;
					}
					var byte:int = encodeBinaryStringToInt(byteStrings[i]);
					//trace("byte",byte);
					bytes.writeByte(byte);
				}
				
				
			}
		}
		
		private function encodeBinaryStringToInt(value:String):int
		{
			var byte:int = 0;
			for(var i:uint = 0; i < value.length; i++)
			{
				byte += int(value.charAt(i)) << value.length - (i+1);
			}
			return byte;
		}
		
		
		public function getBytes():ByteArray
		{
			bytes.position = 0;
			return bytes;
		}
		
		public static function readU29(input:IDataInput):U29
		{
			var byte:int;
			var u29:U29 = new U29();
			
			while(true)
			{
				byte = input.readByte();
				trace("input",byte);
				u29.bytes.writeByte(byte);
				
				if(byte >> 7 == 0) break;
			}
			
			return u29;
		}
		
		public function unpack(items:Array):Array
		{
			var unpacked:Array = [];
			var bitOffset:uint = 0;
			var intValue:int;
			var i:uint;
			
			for(i = 0; i < items.length-1; i++)
			{
				var item:uint = items[i];
				trace("item",item)
				intValue = headerByte >> item & ((1 << item) - 1);
				bitOffset += item;
				trace("intValue",intValue);
				unpacked.push(intValue);
			}
			
			unpacked.push(readIntFromOffset(bitOffset))
			return unpacked;
		}
		
		
		
		public function getBitAt(position:uint):uint
		{
			return (headerByte >> position) & 1;
		}
		
		public function readIntFromOffset(offset:uint):int
		{
			var intBuffer:Vector.<int> = new Vector.<int>();
			var byte:int;
			var i:uint = bytes.length;
			
			while(--i > -1)
			{
				trace("i",i);
				byte = bytes[i];
				trace("byte",byte.toString(2),byte.toString(16));
				if(byte >> 7 == 1) 
				{
					byte -= 0x80;
					trace("int byte",byte);
				}
				var shift:int = (7 * (bytes.length-1 - i)) - offset;
				var intv:int = 0
				if(shift < 0)
				{
					trace("below zero");
					intv = byte >> Math.abs(shift);
				}
				else
				{
					intv = byte << shift;
				}
				trace("shift",shift);
				
				intBuffer.push(intv);
				
			}
			
			var intValue:int = 0;
			while(intBuffer.length > 0) 
			{ 
				intValue += intBuffer.pop() 
			}
			
			return intValue;
		}
		
		public function get headerByte():uint
		{
			return bytes[bytes.length - 1]
		}
		
	}
}