package org.daisy.pipeline.braille.dotify.calabash;

import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;
import java.io.InputStream;

import javax.xml.transform.stream.StreamSource;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;

import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;

import org.daisy.common.xproc.calabash.XProcStepProvider;

import org.daisy.dotify.api.engine.FormatterEngine;
import org.daisy.dotify.api.translator.BrailleTranslatorFactory;
import org.daisy.dotify.api.writer.MediaTypes;
import org.daisy.dotify.api.writer.PagedMediaWriter;
import org.daisy.dotify.consumer.engine.FormatterEngineMaker;
import org.daisy.dotify.consumer.writer.PagedMediaWriterFactoryMaker;

public class OBFLToPEFProvider implements XProcStepProvider {
	
	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new OBFLToPEF(runtime, step);
	}
	
	public class OBFLToPEF extends DefaultStep {
	
		private ReadablePipe source = null;
		private WritablePipe result = null;
		
		private OBFLToPEF(XProcRuntime runtime, XAtomicStep step) {
			super(runtime, step);
		}
	
		@Override
		public void setInput(String port, ReadablePipe pipe) {
			source = pipe;
		}
	
		@Override
		public void setOutput(String port, WritablePipe pipe) {
			result = pipe;
		}
	
		@Override
		public void reset() {
			source.resetReader();
			result.resetWriter();
		}
	
		@Override
		public void run() throws SaxonApiException {
			super.run();
			try {
				
				// Read OBFL
				ByteArrayOutputStream s = new ByteArrayOutputStream();
				Serializer serializer = new Serializer(s);
				serializer.serializeNode(source.read());
				serializer.close();
				InputStream obflStream = new ByteArrayInputStream(s.toByteArray());
				s.close();
				
				// Convert
				PagedMediaWriter writer = PagedMediaWriterFactoryMaker.newInstance()
						.newPagedMediaWriter(MediaTypes.PEF_MEDIA_TYPE);
				FormatterEngine engine = FormatterEngineMaker.newInstance()
						.newFormatterEngine("und", BrailleTranslatorFactory.MODE_BYPASS, writer); // zxx
				s = new ByteArrayOutputStream();
				engine.convert(obflStream, s);
				obflStream.close();
				InputStream pefStream = new ByteArrayInputStream(s.toByteArray());
				s.close();
				
				// Write PEF
				result.write(runtime.getProcessor().newDocumentBuilder().build(new StreamSource(pefStream)));
				pefStream.close();
				
			} catch (Exception e) {
				
				e.printStackTrace();
				
				throw new RuntimeException(e); }
		}
	}
}
