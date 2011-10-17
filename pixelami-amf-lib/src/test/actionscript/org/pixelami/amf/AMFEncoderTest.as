package org.pixelami.amf
{
	import flash.utils.ByteArray;
	
	import mx.utils.ObjectUtil;
	
	import org.flexunit.asserts.assertEquals;
	import org.pixelami.util.Printer;

	public class AMFEncoderTest
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
		public function testEncodeString():void
		{
			var ba:ByteArray = new ByteArray();
			var encoder:AMFEncoder = new AMFEncoder();
			encoder.writeValue(ba,"hello world !");
			ba.position = 0;
			var result:Object = ba.readObject();
			trace("result",result);
			assertEquals("hello world !",result);
		}
		
		
		[Test]
		public function testEncodeObject():void
		{
			var o:Object = {label:"foo",index:0};
			var ba:ByteArray = new ByteArray();
			ba.writeObject(o);
			ba.position = 0;
			Printer.printBits(ba);
			
			ba = new ByteArray()
			var encoder:AMFEncoder = new AMFEncoder();
			encoder.writeValue(ba,o);
			ba.position = 0;
			var result:Object = ba.readObject();
			//trace("result",ObjectUtil.toString(result));
			
			assertEquals(o.label, result.label);
		}
		
	}
}