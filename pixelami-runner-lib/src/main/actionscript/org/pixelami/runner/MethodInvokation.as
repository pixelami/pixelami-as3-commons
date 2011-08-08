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

package org.pixelami.runner
{
	import flash.utils.getTimer;

	public class MethodInvokation
	{
		/**
		 * Sets the number of instances to pool for reuse
		 */
		public static var MAX_INSTANCES:uint = 100;
		
		private static var INVOKATION_INSTANCE_ID:uint = 0;
		
		private static var _instances:Vector.<MethodInvokation> = new Vector.<MethodInvokation>();
		
		/**
		 * @return MethodInvocation instance - use this method to leverage instance pooling strategy
		 */
		public static function getMethodInvokation(method:Function, args:Array, scope:*=null):MethodInvokation
		{
			var mi:MethodInvokation;
			if(_instances.length > 0) 
			{
				mi = _instances.shift();
				mi.method = method;
				mi.args = args;
				mi.scope = scope;
			}
			else
			{
				mi = new MethodInvokation(method,args,scope);
			}
			return mi;
		}
		
		/**
		 * A method to call
		 */
		public var method:Function;
		
		/**
		 * arguments that will be passes to the method when it is called
		 */
		public var args:Array;
		
		/**
		 * The scope in which the method will be called
		 */
		public var scope:*;
		
		public var id:uint;
		
		public function MethodInvokation(method:Function, args:Array, scope:*=null)
		{
			this.method = method;
			this.args = args;
			this.scope = scope;
			id = INVOKATION_INSTANCE_ID++;
		}
		
		/**
		 * executes the method
		 */
		public function execute():void
		{
			this.method.apply(this.scope,this.args);
		}
		
		public function destroy():void
		{
			if(_instances.length < MAX_INSTANCES)
			{
				_instances.push(this);
			}
			
		}
		
		public function toString():String
		{
			return method.length +", "+ id ;
		}
	}
}