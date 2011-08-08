package org.pixelami.amf
{
	import flash.utils.ByteArray;
	
	import mx.utils.ObjectUtil;

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
			var encoder:AMFEncoder = new AMFEncoder(ba);
			encoder.writeValue("hello world !");
			ba.position = 0;
			trace("result",ba.readObject());
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
			var encoder:AMFEncoder = new AMFEncoder(ba);
			encoder.writeValue(o);
			ba.position = 0;
			trace("result",ObjectUtil.toString(ba.readObject()));
		}
		
	}
}