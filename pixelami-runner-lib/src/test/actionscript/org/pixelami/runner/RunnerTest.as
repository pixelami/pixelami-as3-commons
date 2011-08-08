package org.pixelami.runner
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;

	public class RunnerTest
	{		
		public var dispatcher:EventDispatcher = new EventDispatcher();
		
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
		public function dummyTest():void	
		{
			assertTrue(true);
		}
		
		
		[Ignore("The test using org.pixelami.runner.RunnerImpl break in flemojos, but work in Flash Builder 4/4.5")]
		[Test(async,timeout=2000)]
		public function simpleProcessTest():void
		{
			var p:SaySomethingProcess = new SaySomethingProcess();
			p.addEventListener(Event.COMPLETE,asyncCompleteHandler);

			Async.proceedOnEvent(this,dispatcher,Event.COMPLETE,2000,timeoutHandler);
			p.start();
			//p.complete();
		}
		
		private function asyncCompleteHandler(event:Event):void
		{
			dispatcher.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		private function timeoutHandler(event:Event):void
		{
			fail("timeout occured");
		}
	}
}