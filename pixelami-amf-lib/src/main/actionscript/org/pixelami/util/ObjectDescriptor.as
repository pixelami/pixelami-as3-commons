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


// TODO refactor to extend AMFEncoder
package org.pixelami.util
{
	import flash.net.getClassByAlias;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import org.pixelami.amf.AMFEncoder;
	import org.pixelami.amf.ObjectMarker;
	import org.pixelami.amf.U29;
	import org.pixelami.amf.amf_internal;
	
	use namespace amf_internal;
	
	public class ObjectDescriptor extends AMFEncoder implements IExternalizable
	{
		
		private var attributes:Array = [];
		
		public function getAttributes():Array
		{
			return attributes;
		}
		
		private var _type:String;

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}
		
		private var _name:String;

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}
		
		
		public function ObjectDescriptor()
		{
		}
		
		public function addAttribute(attribute:IAttribute):void
		{
			attributes.push(attribute);
		}
		
		public function removeAttribute(attribute:IAttribute):void
		{
			attributes.splice(attributes.indexOf(attribute),1);
		}
		
		public function readExternal(input:IDataInput):void
		{	
		}
		
		public function writeExternal(output:IDataOutput):void
		{
			writeHeader(output);
			writeTraits(output);
			writeValues(output);
		}
		
		internal function writeHeader(output:IDataOutput):void
		{
			// check that we don't already exist as traits reference
			
			var traits:U29
			var traits_ref:Object = referenceTable.traitsTable[type];
			if(traits_ref != null)
			{
				/*
				U29O-traits-ref
				The first (low) bit is a flag with value 1. 
				The second bit is a flag (representing whether a trait reference follows) 
				with value 0 to imply that this objects traits are being sent by reference. 
				The remaining 1 to 27 significant bits are used to encode a trait reference index (an integer).
				*/
				traits = new U29(1,0,uint(traits_ref));
			}
			else
			{
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
				traits = new U29(1,1,0,0,attributes.length);
			}
			
			output.writeByte(ObjectMarker.OBJECT);
			output.writeBytes(traits.getBytes());
			
			if(traits_ref == null)
			{
				// write class name
				writeU29String(output,type);
			}
		}
		
		internal function writeTraits(output:IDataOutput):void
		{
			attributes.sortOn("name");
			
			var trait_ref:Object = referenceTable.traitsTable[type];
			if(trait_ref == null)
			{
			
				for(var i:uint = 0; i < attributes.length; i++)
				{
					var attribute:IAttribute = attributes[i];
					writeU29String(output,attribute.name);
				}
				referenceTable.traitsTable[type] = referenceTable.traitsRefCounter++;
			}
		}
		
		internal function writeValues(output:IDataOutput):void
		{
			for(var i:uint = 0; i < attributes.length; i++)
			{
				var attribute:IAttribute = attributes[i];
				writeValue(output, attribute.value);
			}
		}
		
		override public function writeValue(output:IDataOutput, value:*):void
		{
			var desc:XML = describeType(value);
			var classAlias:String = desc.@alias;
			if(classAlias=="")
			{
				classAlias = getQualifiedClassName(value);
			}
			trace(classAlias,value);
			switch (classAlias)
			{
				case "String": 	
					writeString(output, value); 
					break;
				case "Number": 	
					writeNumber(output, value); 
					break;
				case "int": 
				case "uint": 
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

				default: 		
					writeReferencableObject(output, value, classAlias);
			}
		}
		
		
		override amf_internal function writeObject(output:IDataOutput, value:*, objectType:String):void
		{
			/*
			if(value is ObjectDescriptor)
			{
				ObjectDescriptor(value).referenceTable = referenceTable;
				IExternalizable(value).writeExternal(output);
				return;
			}
			
			super.writeObject(output, value, objectType);
			*/
			
			if(value is ObjectDescriptor)
			{
				ObjectDescriptor(value).referenceTable = this.referenceTable;
				IExternalizable(value).writeExternal(output);
				return;
			}
			
			/*
			U29O-traits-ref
			The first (low) bit is a flag with value 1. 
			The second bit is a flag (representing whether a trait reference follows) 
			with value 0 to imply that this objects traits are being sent by reference. 
			The remaining 1 to 27 significant bits are used to encode a trait reference index (an integer).
			*/
			
			var traits_ref:U29;
			var key:String;
			
			var sealedTraits:Array = TypeUtil.getPropertiesAndAccessors(value);
			
			if(sealedTraits.length > 0)
			{
				var t_ref:Object = referenceTable.traitsTable[objectType];
				if(t_ref != null)
				{
					output.writeByte(ObjectMarker.OBJECT);
					traits_ref = new U29(1,0,uint(t_ref));
					output.writeBytes(traits_ref.getBytes(),0);
					for(i = 0; i < sealedTraits.length; i++)
					{
						key = sealedTraits[i];
						writeValue(output, value[key])
					}
					return;
				}
				else
				{
					if(!(value is ObjectDescriptor))
					{
						referenceTable.traitsTable[objectType] = referenceTable.traitsRefCounter++;
					}
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
			
			if(value is flash.utils.IExternalizable)
			{

				if(value is ObjectDescriptor)
				{
					ObjectDescriptor(value).referenceTable = this.referenceTable;
				}
				else
				{
					output.writeByte(ObjectMarker.OBJECT);
					traits_ext = new U29(1,1,1);
					output.writeBytes(traits_ext.getBytes(),0);
					writeU29String(output,objectType);
				}
				
				IExternalizable(value).writeExternal(output);
				return;
			}
			
			output.writeByte(ObjectMarker.OBJECT);
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
			//var traits:U29 = new U29(1,1,0,dynamicBit,attributes.length);
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
				writeValue(output, value[key])
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
					writeValue(output,value[trait]);
				}
			}
		}
		
		override amf_internal function writeU29Ref(output:IDataOutput, value:*):Boolean
		{
			if(value is ObjectDescriptor) return false;
			return super.writeU29Ref(output, value);
		}
		
	}
}