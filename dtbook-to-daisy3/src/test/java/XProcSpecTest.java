import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

public class XProcSpecTest extends AbstractXSpecAndXProcSpecTest {
	
	@Override
	protected String[] testDependencies() {
		return new String[] {
			pipelineModule("common-utils"),
			pipelineModule("css-speech"),
			pipelineModule("css-utils"),
			pipelineModule("daisy3-utils"),
			pipelineModule("dtbook-tts"),
			pipelineModule("dtbook-utils"),
			pipelineModule("fileset-utils"),
			pipelineModule("file-utils"),
			pipelineModule("tts-helpers"),
			pipelineModule("common-entities"),
			pipelineModule("nlp-omnilang-lexer"),
			pipelineModule("audio-encoder-lame"),
			pipelineModule("tts-adapter-osx"),
		};
	}
}
