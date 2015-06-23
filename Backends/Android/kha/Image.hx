package kha;

import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.opengl.GLES20;
import android.opengl.GLUtils;
import haxe.io.Bytes;
import java.lang.ref.WeakReference;
import java.NativeArray;
import java.nio.Buffer;
import java.nio.ByteBuffer;
import java.io.IOException;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

class Image {
	public static var assets: AssetManager;
	
	private var myWidth: Int;
	private var myHeight: Int;
	private var myRealWidth: Int;
	private var myRealHeight: Int;
	public var tex: Int = -1;
	public var framebuffer: Int = -1;
	//private var buffer: Buffer;
	
	//public function new(name: String) {
	//	this.name = name;
	//}
	
	public function new(width: Int, height: Int, format: TextureFormat, renderTarget: Bool) {
		myWidth = width;
		myHeight = height;
		myRealWidth = upperPowerOfTwo(width);
		myRealHeight = upperPowerOfTwo(height);
		tex = createTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, tex);
		//Sys.gl.pixelStorei(Sys.gl.UNPACK_FLIP_Y_WEBGL, true);
		
		GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
		GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
		GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
		GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
		if (renderTarget) {
			framebuffer = createFramebuffer();
			GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, framebuffer);
			GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, realWidth, realHeight, 0, GLES20.GL_RGBA, format == TextureFormat.RGBA128 ? GLES20.GL_FLOAT : GLES20.GL_UNSIGNED_BYTE, null);
			GLES20.glFramebufferTexture2D(GLES20.GL_FRAMEBUFFER, GLES20.GL_COLOR_ATTACHMENT0, GLES20.GL_TEXTURE_2D, tex, 0);
			GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
		}
		else {
			//GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, GLES20.GL_RGBA, format == TextureFormat.RGBA128 ? GLES20.GL_FLOAT : GLES20.GL_UNSIGNED_BYTE, image);
		}
		//Sys.gl.generateMipmap(Sys.gl.TEXTURE_2D);
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
	}
	
	@:allow(kha.android.Loader)
	private static function createFromFile(filename: String): Image {
		try {
			var b = BitmapFactory.decodeStream(assets.open(filename));
			var image = new Image(b.getWidth(), b.getHeight(), TextureFormat.RGBA32, false);
			GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, image.tex);
			
			GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, image.realWidth, image.realHeight, 0, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, null);
			
			GLUtils.texSubImage2D(GLES20.GL_TEXTURE_2D, 0, 0, 0, b, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE);
			
			//var buffer = ByteBuffer.allocateDirect(b.getWidth() * b.getHeight() * 4);
			//b.copyPixelsToBuffer(buffer);
			//GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, image.realWidth, image.realHeight, 0, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, buffer);
			//GLES20.glTexSubImage2D(GLES20.GL_TEXTURE_2D, 0, 0, 0, b.getWidth(), b.getHeight(), GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, buffer);
			
			//GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, b, 0);
			
			return image;
		}
		catch (ex: IOException) {
			ex.printStackTrace();
			return null;
		}
	}
	
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null, levels: Int = 1): Image {
		if (format == null) format = TextureFormat.RGBA32;
		if (usage == null) usage = Usage.StaticUsage;
		return new Image(width, height, format, false);
	}
	
	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: Bool = false, antiAliasingSamples: Int = 1): Image {
		if (format == null) format = TextureFormat.RGBA32;
		return new Image(width, height, format, true);
	}
	
	public var g2(get, null): kha.graphics2.Graphics;
	
	private function get_g2(): kha.graphics2.Graphics {
		return null;
	}
	
	public var g4(get, null): kha.graphics4.Graphics;
	
	private function get_g4(): kha.graphics4.Graphics {
		return null;
	}
	
	public function unload(): Void {
		if (tex >= 0) {
			var textures = new NativeArray<Int>(0);
			textures[0] = tex;
			GLES20.glDeleteTextures(1, textures, 0);
		}
		if (framebuffer >= 0) {
			var framebuffers = new NativeArray<Int>(0);
			framebuffers[0] = framebuffer;
			GLES20.glDeleteFramebuffers(1, framebuffers, 0);
		}
	}
	
	private static function createFramebuffer(): Int {
		var framebuffers = new NativeArray<Int>(1);
		GLES20.glGenFramebuffers(1, framebuffers, 0);
		return framebuffers[0];
	}
	
	private static function createTexture(): Int {
		var textures = new NativeArray<Int>(1);
		GLES20.glGenTextures(1, textures, 0);
		return textures[0];
	}

	/*public function set(stage: Int): Void {
		GLES20.glActiveTexture(GLES20.GL_TEXTURE0 + stage);
		if (tex == -1) {
			tex = createTexture();
			GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, tex);
			//glContext.pixelStorei(WebGLRenderingContext.UNPACK_FLIP_Y_WEBGL, 1);
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_NEAREST);
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
			GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, getBitmap(), 0);
			//GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, img.getWidth(), img.getHeight(), 0, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, img.getBuffer());
			//GLES20.glUniform1i(textureUniform, GLES20.GL_TEXTURE0);
		}
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, tex);
	}*/
	
	public function set(stage: Int): Void {
		GLES20.glActiveTexture(GLES20.GL_TEXTURE0 + stage);
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, tex);
	}
	
	/*public function getBuffer() : Buffer {
		load();
		if (buffer == null) {
			buffer = ByteBuffer.allocateDirect(getBitmap().getWidth() * getBitmap().getHeight() * 4);
			getBitmap().copyPixelsToBuffer(buffer);
		}
		return buffer;
	}
	
	public function getBitmap(): Bitmap {
		load();
		return b;
	}*/
	
	public var width(get, null): Int;
	
	private function get_width() : Int {
		return myWidth;
	}
	
	public var height(get, null): Int;

	private function get_height() : Int {
		return myHeight;
	}
	
	public var realWidth(get, null): Int;
	
	private function get_realWidth(): Int {
		return myRealWidth;
	}
	
	public var realHeight(get, null): Int;
	
	private function get_realHeight(): Int {
		return myRealHeight;
	}

	public function isOpaque(x : Int, y : Int) : Bool {
		//return (b.getPixel(x, y) >> 24) != 0;
		return false;
	}
	
	public function lock(level: Int = 0): Bytes {
		return null;
	}
	
	public function unlock(): Void {
		
	}
	
	public static var maxSize(get, null): Int;
	
	public static function get_maxSize(): Int {
		return 2048;
	}
	
	public static var nonPow2Supported(get, null): Bool;
	
	public static function get_nonPow2Supported(): Bool {
		return false;
	}
	
	private static function upperPowerOfTwo(v: Int): Int {
		v--;
		v |= v >>> 1;
		v |= v >>> 2;
		v |= v >>> 4;
		v |= v >>> 8;
		v |= v >>> 16;
		v++;
		return v;
	}
}