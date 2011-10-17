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

package org.pixelami.ui.model
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.utils.ObjectUtil;
	
	import org.pixelami.util.RuntimeUtil;

	public class ClassBrowserPM
	{
		[Bindable]
		public var definitionList:IList;
		
		[Bindable]
		public var classReport:String;
		
		public function ClassBrowserPM()
		{
		}
		
		[Init]
		public function init():void
		{
			var allDefinitions = RuntimeUtil.getLoadedClassDefinitions();
			var definitions:Array = [];
			for each (var definition:String in allDefinitions)
			{
				var info:DefinitionInfo = new DefinitionInfo();
				info.name = definition;
				definitions.push(info);
			}
			definitionList = new ArrayCollection(definitions);
		}
		
		public function setFocusedClassName(className:String):void	
		{
			trace(className);
			classReport = className + "\n\n";
			var defintion:Object = getDefinitionByName(className);
			classReport += describeType(defintion)  + "\n\n";
			var classInfo:Object = ObjectUtil.getClassInfo(defintion);
			classReport += ObjectUtil.toString(classInfo.properties);
		}
	}
}