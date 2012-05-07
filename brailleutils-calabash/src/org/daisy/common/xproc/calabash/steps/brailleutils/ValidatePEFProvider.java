package org.daisy.common.xproc.calabash.steps.brailleutils;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.common.xproc.calabash.XProcStepProvider;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;

public class ValidatePEFProvider implements XProcStepProvider {

	private static final QName _message = new QName("", "message");

	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new ValidatePEFStep(runtime, step);
	}

	private class ValidatePEFStep extends DefaultStep {
		private ReadablePipe source = null;
		private WritablePipe result = null;

		/**
		 * Creates a new instance of Identity
		 */
		public ValidatePEFStep(XProcRuntime runtime, XAtomicStep step) {
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

			String message = getOption(_message).getString();
			// System.err.println("Message: " + "Message:"+message);
			runtime.info(this, step.getNode(), "Message:" + message);
			while (source.moreDocuments()) {
				XdmNode doc = source.read();
				runtime.finest(
						this,
						step.getNode(),
						"Message step " + step.getName() + " read "
								+ doc.getDocumentURI());
				result.write(doc);
			}
		}
	}
}
