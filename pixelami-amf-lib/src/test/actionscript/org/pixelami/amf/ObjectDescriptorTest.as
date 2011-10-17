package org.pixelami.amf
{	
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.pixelami.amf.mock.SomeClass;
	import org.pixelami.amf.mock.SomeItem;
	import org.pixelami.util.ObjectDescriptor;
	import org.pixelami.util.Printer;
	import org.pixelami.util.TypedAttribute;
	
	public class ObjectDescriptorTest
	{		
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		
		[Test]
		public function testWriteHeader():void
		{
			var od:ObjectDescriptor = new ObjectDescriptor();
			
			
			var ba:ByteArray = new ByteArray();
			
			var byte:int;
			byte = 1 + (1 << 2);
			od.type = "TypedAttribute";
			od.addAttribute(new TypedAttribute("name",getQualifiedClassName(1.5),1.5));
			od.addAttribute(new TypedAttribute("name",getQualifiedClassName(""),"someValue"));
			od.writeExternal(ba);
			Printer.printBits(ba);
			
		}
		
		[Test]
		public function testWriteObject():void
		{
			
			
			var o:SomeClass = new SomeClass();
			o.property1 = "foo";
			var longString:String = "bar bar bar bar bar " +
				"bar bar bar bar bar bar bar bar bar bar " +
				"bar bar bar bar bar bar bar bar bar bar " +
				"bar bar bar bar bar bar bar bar bar";
			trace("longString.length",longString.length);
			o.property2 = longString;
			
			var className:String = flash.utils.getQualifiedClassName(o);
			registerClassAlias(className,SomeClass);
			
			var od:ObjectDescriptor = new ObjectDescriptor();
			od.type = className;
			
			od.addAttribute(new TypedAttribute("property1",getQualifiedClassName(""),"foo"));
			od.addAttribute(new TypedAttribute("property2",getQualifiedClassName(""),longString));
			
			var ba:ByteArray = new ByteArray();
			ba.writeObject(o);
			Printer.printBits(ba);
			
			ba = new ByteArray();
			od.writeExternal(ba);
			Printer.printBits(ba);
			
			ba.position = 0;
			o = ba.readObject() as SomeClass;
			assertNotNull(o);
			assertEquals("foo",o.property1);
			assertEquals(longString,o.property2);
		}
		
		[Test] 
		public function testU29():void
		{
			var integer:int = 135;
			var u29:U29 = new U29(1,integer);
			trace(integer);
			Printer.printBits(u29.getBytes());
		}
		
		[Test] 
		public function testU29Big():void
		{
			var integer:int = 135;
			var u29:U29 = new U29(1,integer);
			trace(integer);
			Printer.printBits(u29.getBytes());
			
			
		}
		
		[Test]
		public function testWriteArray():void
		{
			var o:SomeClass = new SomeClass();
			o.property1 = "foo";
			var array:Array = [1,2,3];
			o.arrayProperty = array;
			
			var className:String = flash.utils.getQualifiedClassName(o);
			registerClassAlias(className,SomeClass);
			
			var od:ObjectDescriptor = new ObjectDescriptor();
			od.type = className;
			
			od.addAttribute(new TypedAttribute("property1",getQualifiedClassName(""),"foo"));
			od.addAttribute(new TypedAttribute("property2",getQualifiedClassName(null),null));
			od.addAttribute(new TypedAttribute("arrayProperty",getQualifiedClassName([]),array));
			
			var ba:ByteArray = new ByteArray();
			ba.writeObject(o);
			Printer.printBits(ba);
			
			ba = new ByteArray();
			od.writeExternal(ba);
			trace("ARRAY BITS >>>");
			Printer.printBits(ba);
			
			ba.position = 0;
			o = ba.readObject() as SomeClass;
			assertNotNull(o);
			assertTrue(3,o.arrayProperty.length);
			assertTrue(1,o.arrayProperty[0]);
			assertTrue(2,o.arrayProperty[1]);
			assertTrue(3,o.arrayProperty[2]);
			
		}
		
		
		[Test]
		public function testStringReference():void
		{
			var o:SomeClass = new SomeClass();
			o.property1 = "foo";
			var array:Array = ["bar","bar","bar","bar"];
			o.arrayProperty = array;
			
			var className:String = flash.utils.getQualifiedClassName(o);
			registerClassAlias(className,SomeClass);
			
			var od:ObjectDescriptor = new ObjectDescriptor();
			od.type = className;
			
			od.addAttribute(new TypedAttribute("property1",getQualifiedClassName(""),"foo"));
			od.addAttribute(new TypedAttribute("property2",getQualifiedClassName(null),null));
			od.addAttribute(new TypedAttribute("arrayProperty",getQualifiedClassName([]),array));
			
			var ba:ByteArray = new ByteArray();
			ba.writeObject(o);
			Printer.printBits(ba);
			
			ba = new ByteArray();
			od.writeExternal(ba);
			trace("ARRAY BITS >>>");
			Printer.printBits(ba);
			
			ba.position = 0;
			o = ba.readObject() as SomeClass;
			assertNotNull(o);
		}
		
		[Test]
		public function testTraitReference():void
		{
			var o:SomeClass = new SomeClass();
			o.property1 = "foo";
			
			var array:Array = [new SomeItem("bar",1),new SomeItem("bar",2),new SomeItem("bar",3)];
			o.arrayProperty = array;
			
			var className:String = flash.utils.getQualifiedClassName(o);
			registerClassAlias(className,SomeClass);
			
			var od:ObjectDescriptor = new ObjectDescriptor();
			od.type = className;
			
			od.addAttribute(new TypedAttribute("property1",getQualifiedClassName(""),"foo"));
			od.addAttribute(new TypedAttribute("arrayProperty",getQualifiedClassName([]),array));
			
			var ba:ByteArray = new ByteArray();
			ba.writeObject(o);
			Printer.printBits(ba);
			
			ba = new ByteArray();
			od.writeExternal(ba);
			trace("ARRAY BITS >>>");
			Printer.printBits(ba);
			
			ba.position = 0;
			o = ba.readObject() as SomeClass;
			assertNotNull(o);
			assertEquals("foo",o.property1);
			assertEquals(3,o.arrayProperty.length);
			trace("object",ObjectUtil.toString(o));
			var item0:Object = o.arrayProperty[0];
			assertNotNull(item0);
			assertEquals("bar",item0.label);
		}
		
		[Test]
		public function testNestedObjectDescriptor():void
		{
			var ba:ByteArray;
			var className:String = flash.utils.getQualifiedClassName(SomeClass);
			registerClassAlias(className,SomeClass);
			ba = new ByteArray();
			var so1:SomeClass = new SomeClass();
			so1.property1 = "foo";
			so1.property2 = "bar";
			var so2:SomeClass = new SomeClass();
			so2.property1 = "bar";
			so2.property2 = "foo";
			so2.arrayProperty = null;
			so1.arrayProperty = [so2];
			ba.writeObject(so1);
			Printer.printBits(ba);
			
			var od1:ObjectDescriptor = new ObjectDescriptor();
			od1.type = className;
			od1.addAttribute(new TypedAttribute("property1",getQualifiedClassName(""),"bar"));
			od1.addAttribute(new TypedAttribute("property2",getQualifiedClassName(""),"foo"));
			od1.addAttribute(new TypedAttribute("arrayProperty",getQualifiedClassName([]),null));
			
			var od:ObjectDescriptor = new ObjectDescriptor();
			od.type = className;
			od.addAttribute(new TypedAttribute("property1",getQualifiedClassName(""),"foo"));
			od.addAttribute(new TypedAttribute("property2",getQualifiedClassName(""),"bar"));
			od.addAttribute(new TypedAttribute("arrayProperty",getQualifiedClassName([]),[od1]));
			
			ba = new ByteArray();
			od.writeExternal(ba);
			trace("NESTED BITS >>>");
			Printer.printBits(ba);
			ba.position = 0;
			
			var result:Object = ba.readObject();
			trace("nested ObjectDescriptor",ObjectUtil.toString(result));
			assertEquals("foo", result.property1);
			
			var someClass:SomeClass = result as SomeClass;
			var nestedSomeClass:SomeClass = someClass.arrayProperty[0] as SomeClass;
			assertNotNull(nestedSomeClass);
			assertEquals("bar",nestedSomeClass.property1);
		}
		
		
		[Test] 
		public function testArrayObjectDescriptor():void
		{
			var ba:ByteArray;
			var a:Array = [1,2,3];
			
			var o:ObjectDescriptor = new ObjectDescriptor();
			o.type = "Array";
			o.addAttribute(new TypedAttribute("0","uint",1));
			o.addAttribute(new TypedAttribute("1","uint",2));
			o.addAttribute(new TypedAttribute("2","uint",3));
			
			ba = new ByteArray();
			o.writeExternal(ba);
			trace("ARRAY BITS >>>");
			Printer.printBits(ba);
			ba.position = 0;
			
			var result:Object = ba.readObject();
			trace("nested ObjectDescriptor",ObjectUtil.toString(result));
			assertEquals(1, result[0]);
		}
		
		
		[Test] 
		public function testArrayCollectionDescriptor():void
		{
			var ba:ByteArray;
			var a:ArrayCollection = new ArrayCollection([1,2,3]);
			
			var o:ObjectDescriptor = new ObjectDescriptor();
			o.type = "SomeRequest";
			
			var desc:XML = describeType(ArrayCollection);
			var classAlias:String = desc.@alias;
			trace("classAlias",classAlias);
			//o.addAttribute(new TypedAttribute("collection",(getQualifiedClassName(ArrayCollection)),new ArrayCollection([1,2,3])));
			//o.addAttribute(new TypedAttribute("collection","flex.messaging.io.ArrayCollection",new ArrayCollection([1,2,3])));
			o.addAttribute(new TypedAttribute("collection",classAlias,new ArrayCollection([1,2,3])));
			
			//o.addAttribute(new TypedAttribute("1","uint",2));
			//o.addAttribute(new TypedAttribute("2","uint",3));
			
			ba = new ByteArray();
			o.writeExternal(ba);
			trace("NESTED BITS >>>");
			Printer.printBits(ba);
			ba.position = 0;
			
			var result:Object = ba.readObject();
			trace("ObjectDescriptor",ObjectUtil.toString(result));
			var collection:ArrayCollection = result.collection;
			var item0:uint = collection.getItemAt(0) as uint;
			trace("item0",item0);
			assertTrue(1 == item0);
		}
	}
}