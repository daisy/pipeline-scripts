package org.daisy.common.xproc.calabash.steps.braillecss;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.Iterator;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;

import cz.vutbr.web.css.CSSFactory;
import cz.vutbr.web.css.NodeData;
import cz.vutbr.web.css.StyleSheet;
import cz.vutbr.web.domassign.Analyzer;
import cz.vutbr.web.domassign.StyleMap;

import net.sf.saxon.dom.DocumentOverNodeInfo;
import net.sf.saxon.dom.NodeOverNodeInfo;
import net.sf.saxon.om.NameOfNode;
import net.sf.saxon.om.NamespaceBinding;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.util.NamespaceIterator;

import org.daisy.braillecss.BrailleCSSNodeData;
import org.daisy.braillecss.SupportedBrailleCSS;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;

public class ApplyStylesheet extends DefaultStep {

	private static final String BRL_NS = "http://www.daisy.org/ns/pipeline/braille";
	private static final String BRL_PREFIX = "brl";
	private static final QName BRL_STYLE = new QName(BRL_PREFIX, BRL_NS, "style");
	
	static {
		CSSFactory.registerSupportedCSS(SupportedBrailleCSS.getInstance());
		CSSFactory.registerNodeDataInstance(BrailleCSSNodeData.class);
	}

	private static final QName _stylesheet = new QName("stylesheet");

	private ReadablePipe sourcePipe = null;
	private WritablePipe resultPipe = null;
	
	public ApplyStylesheet(XProcRuntime runtime, XAtomicStep step) {
		super(runtime, step);
	}

	@Override
	public void setInput(String port, ReadablePipe pipe) {
		sourcePipe = pipe;
	}

	@Override
	public void setOutput(String port, WritablePipe pipe) {
		resultPipe = pipe;
	}

	@Override
	public void reset() {
		sourcePipe.resetReader();
		resultPipe.resetWriter();
	}

	@Override
	public void run() throws SaxonApiException {
		
		super.run();

		try {
			
			XdmNode source = sourcePipe.read();
			Document doc = (Document)DocumentOverNodeInfo.wrap(source.getUnderlyingNode());
	        StyleSheet css = CSSFactory.parse(new URI(getOption(_stylesheet).getString()).toURL(), null);
			Analyzer analyzer = new Analyzer(css);
			final StyleMap map = analyzer.evaluateDOM(doc, "all", false);
			resultPipe.write((new MyTreeWriter(doc, map, runtime)).getResult());
			
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	private static class MyTreeWriter extends TreeWriter {
		
		private final StyleMap styleMap;
		
		public MyTreeWriter(Document document, StyleMap styleMap, XProcRuntime xproc)
				throws XPathException, URISyntaxException {
			
			super(xproc);
			this.styleMap = styleMap;
			startDocument(new URI(document.getBaseURI()));
            traverse(document.getDocumentElement());
            endDocument();
		}
		
		private void traverse(Node node) throws XPathException, URISyntaxException {
			
	        if (node.getNodeType() == Node.ELEMENT_NODE) {
	            addStartElement((Element)node);
	            NamedNodeMap attributes = node.getAttributes();
	            for (int i=0; i<attributes.getLength(); i++) {
	            	Node attr = attributes.item(i);
	            	if (!"xmlns".equals(attr.getPrefix())) {
	            		addAttribute(new QName(attr.getNamespaceURI(), attr.getLocalName()), attr.getNodeValue());
	            	}
	            }
	            NodeData data = styleMap.get((Element)node);
				if (data != null) {
					String style = String.valueOf(data).replaceAll("\\s+", "").trim();
					if (style.length() > 0) {
						addAttribute(BRL_STYLE, style);
					}
				}
                receiver.startContent();
                for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling()) {
		            traverse(child);
		        }
	            addEndElement();
	        } else if (node.getNodeType() == Node.COMMENT_NODE) {
	            addComment(node.getNodeValue());
	        } else if (node.getNodeType() == Node.TEXT_NODE) {
	            addText(node.getNodeValue());
	        } else if (node.getNodeType() == Node.PROCESSING_INSTRUCTION_NODE) {
	            addPI(node.getLocalName(), node.getNodeValue());
	        } else {
	            throw new UnsupportedOperationException("Unexpected node type");
	        }
		}
		
		public void addStartElement(Element element) {
			
			NodeInfo inode = ((NodeOverNodeInfo)element).getUnderlyingNodeInfo();
			NamespaceBinding[] inscopeNS = null;
	        if (seenRoot) {
	            inscopeNS = inode.getDeclaredNamespaces(null);
	        } else {
	            int count = 0;
	            Iterator<NamespaceBinding> nsiter = NamespaceIterator.iterateNamespaces(inode);
	            while (nsiter.hasNext()) {
	                count++;
	                nsiter.next();
	            }
	            inscopeNS = new NamespaceBinding[count];
	            nsiter = NamespaceIterator.iterateNamespaces(inode);
	            count = 0;
	            while (nsiter.hasNext()) {
	                inscopeNS[count] = nsiter.next();
	                count++;
	            }
	            seenRoot = true;
	        }
	        receiver.setSystemId(element.getBaseURI());
	        addStartElement(new NameOfNode(inode), inode.getSchemaType(), inscopeNS);
		}
	}
}