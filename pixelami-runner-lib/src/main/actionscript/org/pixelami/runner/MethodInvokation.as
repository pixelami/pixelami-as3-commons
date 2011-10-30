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
		
		private var _childInvokations:Vector.<MethodInvokation> = new Vector.<MethodInvokation>();
		
		public var parent:MethodInvokation;
		
		/**
		 * @return MethodInvocation instance - use this method to leverage instance pooling strategy
		 */
		public static function getMethodInvokation(method:Function, args:Array=null, scope:*=null):MethodInvokation
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
		
		private var _id:uint;
		public function get id():uint
		{
			return _id;
		}
		
		private var _executed:Boolean;
		
		
		
		public function MethodInvokation(method:Function, args:Array, scope:*=null)
		{
			this.method = method;
			this.args = args;
			this.scope = scope;
			_id = INVOKATION_INSTANCE_ID++;
		}
		
		
		/**
		 * executes the method
		 */
		public function execute():void
		{
			this.method.apply(this.scope,this.args);
			_executed = true;
		}
		
		
		public function addChildInvokation(methodInvokation:MethodInvokation):void
		{
			methodInvokation.parent = this;
			_childInvokations.push(methodInvokation);
		}
		
		public function getNextInvokation():MethodInvokation
		{
			// we should be returned first so that any new invokations 
			// created as a result of our execution can be added to our children
			if(!_executed) return this;
			// if we have had children then return them FIFO
			if(_childInvokations.length > 0) return _childInvokations.shift();
			// we've been executed and so have all our children
			// so let's recyle ourself
			recycle();
			// we have a parent so pass the reference to the next invokation
			if(parent) return parent.getNextInvokation();
			// we've exhausted all avenues, we must be back at root.
			return null;
		}
		
		public function toString():String
		{
			var pid:String = parent ? String(parent.id) : "null"
			return "Invokation - [id=" + _id + " parent id=" + pid + "]";
		}
		
		protected function recycle():void
		{
			if(_instances.length < MAX_INSTANCES)
			{
				// reset the instance.
				_executed = false;
				this.method = null;
				this.args = null;
				this.scope = null;
				
				_instances.push(this);
			}
			
		}
		
	}
}