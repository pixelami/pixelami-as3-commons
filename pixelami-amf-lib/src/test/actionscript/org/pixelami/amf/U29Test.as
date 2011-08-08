package org.pixelami.amf
{
	import flash.utils.ByteArray;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;

	public class U29Test
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
		public function testGetBitAt():void
		{
			var u29:U29;
			var ba:ByteArray = new ByteArray();
			ba.writeByte(0x10);
			ba.position = 0;
			u29 = U29.readU29(ba);

			assertEquals(1,u29.getBitAt(4));
			assertEquals(0,u29.getBitAt(2));
		}
	}
}