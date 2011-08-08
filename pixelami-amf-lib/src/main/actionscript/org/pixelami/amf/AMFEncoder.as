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
	import flash.utils.Dictionary;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.utils.getQualifiedClassName;
	import flash.xml.XMLDocument;
	

	public class AMFEncoder
	{
		private var objectRefCounter:int = -1;
		private var traitsRefCounter:int = -1;
		private var stringRefCounter:int = -1;
		
		private var traitsTable:Object = {};
		private var stringsTable:Object = {};
		private var objectsTable:Dictionary = new Dictionary(true);
		
		private var output:IDataOutput;
		
		public function AMFEncoder(output:IDataOutput)
		{
			this.output = output;
		}
		
		public function writeValue(value:*):void
		{
			var className:String = getQualifiedClassName(value);
			trace(className,value);
			switch (className)
			{
				case "String": 	
					writeString(output, value); 
					break;
				case "Number": 	
					writeNumber(output, value); 
					break;
				case "int": 	
					writeInt(output, value);
					break;
				
				case "void":	
					writeUndefined(output); 
					break;
				
				case "null": 	
					writeNull(output); 
					break;
				
				case "Boolean": 
					writeBoolean(output,value); 
					break;
				/*
				case "XML":	
				case "XMLDocument":
				case "Date": 	
				case "Array": 	
				case "Object": 	
				writeReferencableObject(output, value, className);
				*/
				default: 		
					writeReferencableObject(output, value, className);
			}
		}
		
		private function writeReferencableObject(output:IDataOutput, value:*, objectType:String):void
		{
			if(writeU29Ref(output,value)) return ;
			
			switch(objectType)
			{
				case "XML": 	
					writeXML(output,value); 
					break;
				
				case "XMLDocument":
					writeXMLDoc(output,value);
					
				case "Date": 	
					writeDate(output,value); 
					break;
				
				case "Array": 	
					writeArray(output, value); 
					break;
				
				case "Object": 	
					writeObject(output, value, objectType); 
					break;
				default: 	
					writeObject(output, value, objectType);
			}
		}
		
		
		private function writeType(output:IDataOutput, value:*, className:String):void
		{
			// TODO Auto Generated method stub
			
		}
		
		private function writeU29Ref(output:IDataOutput,value:*):Boolean
		{
			/*
			U29O-ref = U29
			The first (low) bit is a flag (representing whether an instance follows) with value 0 to imply that
			this is not an instance but a reference. 
			The remaining 1 to 28 significant bits are used to encode an object reference index (an integer).
			*/
			var object_ref:Object = objectsTable[value];
			if(object_ref != null)
			{
				output.writeBytes(new U29(0,uint(object_ref)).getBytes());
				return true;
			}
			objectsTable[value] = objectRefCounter++;
			return false;
		}
		
		private function writeObject(output:IDataOutput, value:*, objectType:String):void
		{
			
			/*
			U29O-traits-ref
			The first (low) bit is a flag with value 1. 
			The second bit is a flag (representing whether a trait reference follows) 
			with value 0 to imply that this objects traits are being sent by reference. 
			The remaining 1 to 27 significant bits are used to encode a trait reference index (an integer).
			*/
			
			output.writeByte(ObjectMarker.OBJECT);
			
			
			
			var traits_ref:U29;
			var key:String;
			
			var sealedTraits:Array = TypeUtil.getPropertiesAndAccessors(value);
			
			if(sealedTraits.length > 0)
			{
				var t_ref:Object = traitsTable[objectType];
				if(t_ref != null)
				{
					//trait_refs.push(t_ref);
					trace("trait ref",t_ref);
					traits_ref = new U29(1,0,uint(t_ref));
					output.writeBytes(traits_ref.getBytes(),0);
					//writeValue(output,value[key]);
					for(i = 0; i < sealedTraits.length; i++)
					{
						key = sealedTraits[i];
						writeValue(value[key])
					}
					return;
				}
				else
				{
					traitsTable[objectType] = traitsRefCounter++;
				}
				
			}
			
			
			
			/*
			U29O-traits-ext
			The first (low) bit is a flag with value 1. 
			The second bit is a flag with value 1. 
			The third bit is a flag with value 1. 
			The remaining 1 to 26 significant bits are not significant
			(the traits member count would always be 0).
			*/
			var traits_ext:U29;
			
			if(value is IExternalizable)
			{
				traits_ext = new U29(1,1,1);
				output.writeBytes(traits_ext.getBytes(),0);
				IExternalizable(value).writeExternal(output);
				return;
			}
			
			
			// do we have some dynamic props ?
			// if so we know to know in order to set the dynamicBit flag
			var dynamicBit:int = 0;
			var dynamicTraits:Array = getKeys(value);
			if(dynamicTraits.length > 0)
			{
				// we have dynamic properties
				dynamicBit = 1;
			}
			
			
			/*
			The first (low) bit is a flag with value 1. 
			The second bit is a flag with value 1. 
			The third bit is a flag with value 0. 
			The fourth bit is a flag specifying whether the type is dynamic. 
			A value of 0 implies not dynamic, a value of 1 implies dynamic.
			Dynamic types may have a set of name value pairs for dynamic members after the sealed member section. 
			The remaining 1 to 25 significant bits are used to encode the number of sealed traits member names 
			that follow after the class name (an integer).
			*/
			var traits:U29 = new U29(1,1,0,dynamicBit,sealedTraits.length);
			output.writeBytes(traits.getBytes(),0);
			
			var registered:Boolean;
			
			try 
			{
				var clazz:Class = getClassByAlias(objectType);
				registered = true;
			}
			catch(e:ReferenceError)
			{
				registered = false;
			}

			
			
			if(objectType == "Object" || !registered )
			{
				output.writeByte(0x01);
			}
			else
			{
				writeU29String(output,objectType);
			}
			
			var i:uint;
			
			for(i = 0; i < sealedTraits.length; i++)
			{
				key = sealedTraits[i];
				writeU29String(output,key);
			}
			
			for(i = 0; i < sealedTraits.length; i++)
			{
				key = sealedTraits[i];
				writeValue(value[key])
			}
			
			
			/*
			class-name	= UTF-8-vr
			dynamic-member = UTF-8-vr value-type
			; Note: use the empty string for ; anonymous classes.
			; Another dynamic member follows ;untilthestring-typeisthe ; empty string.
			object-type = object-marker 
			( U29O-ref 
			| (U29O-traits-ext class-name *(U8)) 
			| U29O-traits-ref 
			| (U29O- traits class-name *(UTF-8-vr))
			) 
			*(value-type) *(dynamic-member)))
			*/
			
			if(dynamicBit)
			{
				for each(var trait:String in dynamicTraits)
				{
					writeU29String(output,trait);
					writeValue(value[trait]);
				}
				// write empty string to denote end of dynamic traits
				output.writeByte(0x01);
			}
			
		}
		
		private function getKeys(value:*):Array
		{
			var keys:Array = [];
			for(var k:String in value)
			{
				keys.push(k);
			}
			return keys;
		}
		
		private function writeArray(output:IDataOutput, value:*):void
		{
			/*
			U29A-value = U29
			The first (low) bit is a flag with value 1.
			The remaining 1 to 28 significant bits are used to encode the count of the dense portion of the Array.
			
			assoc-value = UTF-8-vr value-type
			array-type = array-marker (U29O-ref | (U29A-value (UTF-8-empty | *(assoc-value) UTF-8-empty) *(value-type)))
			*/
			var UTF8_EMPTY:int = 0x01;
			output.writeByte(ObjectMarker.ARRAY);
			var header:U29 = new U29(1,(value as Array).length);
			output.writeBytes(header.getBytes(),0);
			// TODO handle assoc arrays
			output.writeByte(UTF8_EMPTY);
			
			for each(var o:Object in (value as Array))
			{
				writeValue(o);
			}
			
			
		}
		
		private function writeInt(output:IDataOutput, value:*):void
		{
			output.writeByte(ObjectMarker.INTEGER);
			output.writeBytes(new U29(value).getBytes(),0);
		}
		
		private function writeNumber(output:IDataOutput, value:*):void
		{
			output.writeByte(ObjectMarker.DOUBLE);
			output.writeDouble(value);
		}
		
		private function writeString(output:IDataOutput, value:*):void
		{
			output.writeByte(ObjectMarker.STRING);
			writeU29String(output,value);
		}
		
		private function writeDate(output:IDataOutput, value:*):void
		{
			output.writeByte(ObjectMarker.DATE);
			output.writeBytes(new U29(1).getBytes(),0);
			output.writeDouble((value as Date).time);
		}
		
		private function writeXML(output:IDataOutput, value:*):void
		{
			output.writeByte(ObjectMarker.XML);
			var xmlstr:String = XML(value).toString();
			output.writeBytes(new U29(1,xmlstr.length).getBytes(),0);
			output.writeUTFBytes(xmlstr);
			
		}
		
		private function writeXMLDoc(output:IDataOutput, value:*):void
		{
			output.writeByte(ObjectMarker.XMLDOC);
			var xmlstr:String = XMLDocument(value).toString();
			output.writeBytes(new U29(1, xmlstr.length).getBytes());
			output.writeUTFBytes(xmlstr);
		}
		
		private function writeBoolean(output:IDataOutput, value:*):void
		{
			output.writeByte(value?ObjectMarker.TRUE:ObjectMarker.FALSE);
		}
		
		private function writeNull(output:IDataOutput):void
		{
			output.writeByte(ObjectMarker.NULL);
			
		}
		
		private function writeUndefined(output:IDataOutput):void
		{
			output.writeByte(ObjectMarker.UNDEFINED);
		}		
		
		private function writeU29String(output:IDataOutput,value:String):void
		{
			var marker:U29;
			var string_ref:Object = stringsTable[value];
			if(string_ref == null)
			{
				// TODO this needs to represent the encoded byte length.
				marker = new U29(1, value.length);
			}
			else
			{
				marker = new U29(0, uint(string_ref));
				output.writeBytes(marker.getBytes(),0);
				return;
			}
			output.writeBytes(marker.getBytes(),0);
			output.writeUTFBytes(value);
		}
		
		
	}
}
