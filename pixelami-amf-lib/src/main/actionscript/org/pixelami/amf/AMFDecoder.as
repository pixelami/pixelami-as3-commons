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
	import flash.net.getClassByAlias;
	import flash.utils.ByteArray;
	import flash.utils.IExternalizable;
	import flash.xml.XMLDocument;
	
	//import org.pixelami.utils.ObjectUtil;

	public class AMFDecoder
	{
		private var objectsRefCounter:int = 0;
		private var traitsRefCounter:int = 0;
		private var stringsRefCounter:int = 0;
		
		private var objectsTable:Object = {};
		private var traitsTable:Object = {};
		private var stringsTable:Object = {};
		
		private var bytes:ByteArray;
		public function AMFDecoder(bytes:ByteArray)
		{
			this.bytes = bytes;
		}
		
		public function readValue():*
		{
			var value:*;
			var marker:uint = bytes.readByte();
			switch(marker)
			{
				case ObjectMarker.INTEGER:
					value = readInteger();
					break;
				
				case ObjectMarker.DOUBLE:
					value = readDouble();
					break;
				
				case ObjectMarker.FALSE:
				case ObjectMarker.TRUE:
					value = readBoolean(marker);
					break;
				
				case ObjectMarker.NULL:
					value = readNull();
					break;
				
				case ObjectMarker.UNDEFINED:
					value = readUndefined();
					break;
				
				case ObjectMarker.STRING:
					value = readString();
					break;
				
				case ObjectMarker.ARRAY:
				case ObjectMarker.OBJECT:
				case ObjectMarker.DATE:
				case ObjectMarker.XML:
				case ObjectMarker.XMLDOC:
					value = _readReferencableObject(marker);
					break;
				
			}
			
			return value;
		}
		
		internal function _readReferencableObject(marker:uint):*
		{
			var object:*;
			var u29O:U29 = U29.readU29(bytes);
			if(u29O.getBitAt(0) == 0)
			{
				var refId:uint = u29O.readIntFromOffset(1);
				object = objectsTable[refId];
				return object;
			}
			else
			{
				switch(marker)
				{
					case ObjectMarker.ARRAY:
						object = readArray(u29O);
						break;
					
					case ObjectMarker.OBJECT:
						object = readObject(u29O);
						break;
					
					case ObjectMarker.DATE:
						object = readDate(u29O);
						break;
					
					case ObjectMarker.XML:
						object = readXML(u29O);
						break;
					
					case ObjectMarker.XMLDOC:
						object = readXMLDOC(u29O);
						break;
				}
				
			}
			objectsTable[objectsRefCounter++] = object;
			return object;
			
		}
		
		internal function readObject(u29O:U29):Object
		{
			var object:*;
			var traits:Array = [];
			var values:Array = [];
			var refId:int;
			var dynamicFlag:uint = 0;
			var clazz:Class;
			
			var traitsRef:int = u29O.getBitAt(1);
			if(traitsRef == 0)
			{
				refId = u29O.readIntFromOffset(2);
				var tref:TraitRef = traitsTable[refId];
				if(!tref)
				{
					throw new Error("no trait found with refId "+refId);
				}
				traits = tref.traits;
				
				try
				{
					clazz = getClassByAlias(tref.className);
					object = new clazz();
					
				}
				catch(e:ReferenceError)
				{
					trace("WARNING: No class definition found with alias of "+className);
					trace(e);
					object = {};
				}
			}
			else
			{
				var className:String = readString();
				if(className == "")
				{
					object = {};
				}
				else
				{
					try
					{
						clazz = getClassByAlias(className);
						object = new clazz();
						
					}
					catch(e:ReferenceError)
					{
						trace("WARNING: No class definition found with alias of "+className);
						trace(e);
						object = {};
					}
				}
				
				
				// check for traits-ext or traits
				var traitsExt:int = u29O.getBitAt(2);
				if(traitsExt == 1)
				{
					if(object is IExternalizable)
					{
						IExternalizable(object).readExternal(bytes);
						// TODO - can an IExternalizable have dynamic traits too ?
						return object;
					}
				}
				else
				{
					// we have inline traits after class def
					var traitsLength:uint = u29O.readIntFromOffset(4);
					
					for (var i:uint = 0; i < traitsLength; i++)
					{
						traits.push(readString());
					}
					
					// add this objects traits to the traitsTable
					traitsTable[traitsRefCounter++] = new TraitRef(className, traits.slice());
					//trace(ObjectUtil.toString(traitsTable));
				}
			}
			trace("traits",traits);
			
			for (i = 0; i < traits.length; i++)
			{
				values.push(readValue());
			}
			
			for(i = 0;i < traits.length;i++)
			{
				object[traits[i]] = values[i];
			}
			
			
			dynamicFlag = u29O.getBitAt(3);
			
			if(dynamicFlag)
			{
				while(true)
				{
					var key:String = readString();
					if(key == "") break;
					object[key] = readValue();
				}
			}
			
			return object;
		}
		
		internal function readArray(u29A:U29):Array
		{
			var length:int = u29A.readIntFromOffset(1);
			var a:Array = [];
			
			// read assoc keys and values
			while(true)
			{
				var key:String = readString();
				if(key == "") break;
				a[key] = readValue();
			}
			
			for (var i:uint = 0; i < length; i++)
			{
				a.push(readValue())
			}
			
			return a;
		}
		
		internal function readDate(u29D:U29):Date
		{
			var date:Date = new Date();
			date.time = bytes.readDouble();
			return date;
		}
		
		internal function readXML(u29X:U29):XML
		{
			var l:uint = u29X.readIntFromOffset(1);
			var xmlString:String = bytes.readUTFBytes(l);
			var xml:XML = new XML(xmlString);
			return xml;
		}
		
		internal function readXMLDOC(u29X:U29):XMLDocument
		{
			var l:uint = u29X.readIntFromOffset(1);
			var xmlString:String = bytes.readUTFBytes(l);
			var xmlDoc:XMLDocument = new XMLDocument(xmlString);
			return xmlDoc;
		}
		
		internal function readInteger():int
		{
			return U29.readU29(bytes).readIntFromOffset(0);
		}
		
		internal function readDouble():Number
		{
			return bytes.readDouble();
		}
		
		internal function readBoolean(marker:uint):Boolean
		{
			return marker == ObjectMarker.TRUE;
		}
		
		internal function readNull():*
		{
			return null;
		}
		
		internal function readUndefined():*
		{
			return undefined;
		}
		
		internal function readString():String
		{
			
			var u29S:U29 = U29.readU29(bytes);
			var string:String;
			
			if(u29S.getBitAt(0) == 0)
			{
				var refId:int = u29S.readIntFromOffset(1);
				return stringsTable[refId];
			}
			else
			{
				var length:int = u29S.readIntFromOffset(1);
				string = bytes.readUTFBytes(length);
				if(string != "") 
				{
					stringsTable[stringsRefCounter++] = string;
				}
			}
			return string;
		}
	}
}

class TraitRef
{
	public var className:String;
	public var traits:Array;
	public function TraitRef(className:String, traits:Array)
	{
		this.className = className;
		this.traits = traits;
	}
}