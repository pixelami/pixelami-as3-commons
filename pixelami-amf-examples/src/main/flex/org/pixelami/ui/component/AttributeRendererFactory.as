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

package org.pixelami.ui.component
{
	import mx.core.ClassFactory;
	
	import org.pixelami.ui.model.ObjectComposerPM;
	
	public class AttributeRendererFactory extends ClassFactory
	{
		public var composerModel:ObjectComposerPM;
		
		override public function newInstance():*
		{
			var instance:* = new generator(); 
			instance.model = composerModel;
			return instance;
		}
	}
}