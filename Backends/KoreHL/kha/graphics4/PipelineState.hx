package kha.graphics4;

import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexElement;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

class PipelineState extends PipelineStateBase {
	private var pipeline: Pointer;
	
	public function new() {
		super();
		init();
	}
	
	private function init(): Void {
		pipeline = kore_create_pipeline();
	}

	public function delete() {
		
	}
	
	private function linkWithStructures2(structure0: VertexStructure, structure1: VertexStructure, structure2: VertexStructure, structure3: VertexStructure, size: Int): Void {
		kore_pipeline_set_vertex_shader(pipeline, vertexShader._shader);
		kore_pipeline_set_fragment_shader(pipeline, fragmentShader._shader);		
		if (geometryShader != null) kore_pipeline_set_geometry_shader(pipeline, geometryShader._shader);
		if (tessellationControlShader != null) kore_pipeline_set_tesscontrol_shader(pipeline, tessellationControlShader._shader);
		if (tessellationEvaluationShader != null) kore_pipeline_set_tesseval_shader(pipeline, tessellationEvaluationShader._shader);

		var kore_structure = VertexBuffer.kore_create_vertexstructure();
		for (i in 0...structure0.size()) {
			var data: Int = 0;
			switch (structure0.get(i).data.getIndex()) {
			case 0:
				data = 1;
			case 1:
				data = 2;
			case 2:
				data = 3;
			case 3:
				data = 4;
			case 4:
				data = 5;
			}
			VertexBuffer.kore_vertexstructure_add(kore_structure, StringHelper.convert(structure0.get(i).name), data);
		}
		
		kore_pipeline_compile(pipeline, kore_structure);
	}
	
	public function compile(): Void {
		kore_pipeline_set_states(pipeline,
			cullMode.getIndex(), depthMode.getIndex(), stencilMode.getIndex(), stencilBothPass.getIndex(), stencilDepthFail.getIndex(), stencilFail.getIndex(),
			getBlendFunc(blendSource), getBlendFunc(blendDestination), getBlendFunc(alphaBlendSource), getBlendFunc(alphaBlendDestination),
			depthWrite, stencilReferenceValue, stencilReadMask, stencilWriteMask,
			colorWriteMaskRed, colorWriteMaskGreen, colorWriteMaskBlue, colorWriteMaskAlpha,
			conservativeRasterization);
		linkWithStructures2(
			inputLayout.length > 0 ? inputLayout[0] : null,
			inputLayout.length > 1 ? inputLayout[1] : null,
			inputLayout.length > 2 ? inputLayout[2] : null,
			inputLayout.length > 3 ? inputLayout[3] : null,
			inputLayout.length);
	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		return new kha.korehl.graphics4.ConstantLocation(kore_pipeline_get_constantlocation(pipeline, StringHelper.convert(name)));
	}
	
	
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		return new kha.korehl.graphics4.TextureUnit(kore_pipeline_get_textureunit(pipeline, StringHelper.convert(name)));
	}

	private static function getBlendFunc(factor: BlendingFactor): Int {
		switch (factor) {
		case BlendOne, Undefined:
			return 0;
		case BlendZero:
			return 1;
		case SourceAlpha:
			return 2;
		case DestinationAlpha:
			return 3;
		case InverseSourceAlpha:
			return 4;
		case InverseDestinationAlpha:
			return 5;
		case SourceColor:
			return 6;
		case DestinationColor:
			return 7;
		case InverseSourceColor:
			return 8;
		case InverseDestinationColor:
			return 9;
		default:
			return 0;
		}
	}
	
	public function set(): Void {
		kore_pipeline_set(pipeline);
	}
	
	public function unused(): Void {
		var include1 = new VertexElement("include", VertexData.Float2);
		var include2 = new VertexShader(null, null);
		var include3 = new FragmentShader(null, null);
		// var include4 = new GeometryShader(null);
		// var include5 = new TessellationControlShader(null);
		// var include6 = new TessellationEvaluationShader(null);
	}
	
	@:hlNative("std", "kore_create_pipeline") static function kore_create_pipeline(): Pointer { return null; }
	@:hlNative("std", "kore_pipeline_set_fragment_shader") static function kore_pipeline_set_fragment_shader(pipeline: Pointer, shader: Pointer): Void { }
	@:hlNative("std", "kore_pipeline_set_vertex_shader") static function kore_pipeline_set_vertex_shader(pipeline: Pointer, shader: Pointer): Void { }
	@:hlNative("std", "kore_pipeline_set_geometry_shader") static function kore_pipeline_set_geometry_shader(pipeline: Pointer, shader: Pointer): Void { }
	@:hlNative("std", "kore_pipeline_set_tesscontrol_shader") static function kore_pipeline_set_tesscontrol_shader(pipeline: Pointer, shader: Pointer): Void { }
	@:hlNative("std", "kore_pipeline_set_tesseval_shader") static function kore_pipeline_set_tesseval_shader(pipeline: Pointer, shader: Pointer): Void { }
	@:hlNative("std", "kore_pipeline_compile") static function kore_pipeline_compile(pipeline: Pointer, structure: Pointer): Void { }
	@:hlNative("std", "kore_pipeline_get_constantlocation") static function kore_pipeline_get_constantlocation(pipeline: Pointer, name: hl.Bytes): Pointer { return null; }
	@:hlNative("std", "kore_pipeline_get_textureunit") static function kore_pipeline_get_textureunit(pipeline: Pointer, name: hl.Bytes): Pointer { return null; }
	@:hlNative("std", "kore_pipeline_set_states") static function kore_pipeline_set_states(pipeline: Pointer,
		cullMode: Int, depthMode: Int, stencilMode: Int, stencilBothPass: Int, stencilDepthFail: Int, stencilFail: Int,
		blendSource: Int, blendDestination: Int, alphaBlendSource: Int, alphaBlendDestination: Int,
		depthWrite: Bool, stencilReferenceValue: Int, stencilReadMask: Int, stencilWriteMask: Int,
		colorWriteMaskRed: Bool, colorWriteMaskGreen: Bool, colorWriteMaskBlue: Bool, colorWriteMaskAlpha: Bool,
		conservativeRasterization: Bool): Void { }
	@:hlNative("std", "kore_pipeline_set") static function kore_pipeline_set(pipeline: Pointer): Void { }
}
