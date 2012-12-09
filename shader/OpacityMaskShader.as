package shader
{
	import aerys.minko.render.material.basic.BasicProperties;
	import aerys.minko.render.material.basic.BasicShader;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.ShaderSettings;
	import aerys.minko.type.enum.Blending;

	/**
	 * Opacity Mask Shader.
	 * Purpose : gray-scale map applied to a plane to determine transparency on it.
	 * 
	 * Warning : this shader use the diffuse map to create the opacity mask,
	 * you may want to use the diffuse map to different purpose, so you have to create a different shader.
	 * 
	 * 
	 * @author Ludovic Bas - www.loudoweb.fr
	 * 
	 * @example
	 * <p>
	 * mesh.material.setProperty('OpacityMaskPriority',-2);
	 * mesh.material.effect  = new Effect(new OpacityMaskShader());
	 * </p>
	 **/
	public class OpacityMaskShader extends BasicShader
	{

		private var _alphaThreshold:Number = 0.05;
		
		public function OpacityMaskShader()
		{
			super();
			
		}
		override protected function initializeSettings(settings:ShaderSettings):void{
			settings.blending = Blending.ALPHA;
			//because of the use of alpha blending, default priority is -0.5 (transparency must be calculated last).
			settings.priority = meshBindings.getConstant('OpacityMaskPriority', -0.5);
			settings.depthSortDrawCalls = true;
		}
		override protected function getPixelColor() : SFloat
		{
			var diffuseColor : SFloat;
			if (meshBindings.propertyExists(BasicProperties.DIFFUSE_COLOR))
			{
				diffuseColor = meshBindings.getParameter(BasicProperties.DIFFUSE_COLOR, 4);
			}
			else
			{
				diffuseColor = float4(0., 0., 0., 1.);
			}
			
			var diffuseMap	: SFloat;
			if (meshBindings.propertyExists(BasicProperties.DIFFUSE_MAP))
			{
				
				diffuseMap	= meshBindings.getTextureParameter(
					BasicProperties.DIFFUSE_MAP
				);
				
				
				diffuseMap = sampleTexture(diffuseMap,interpolate(vertexUV));
			}
			
			if(diffuseMap){
				kill(subtract(0.5, lessThan(diffuseMap.r, _alphaThreshold)));
				return float4(diffuseColor.rgb, diffuseMap.r);
			}else{
				return diffuseColor;
			}
			
		}
	}
}