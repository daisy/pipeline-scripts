package org.daisy.braille.css.calabash;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;

import javax.xml.transform.URIResolver;

import com.google.common.collect.Iterables;
import com.google.common.collect.Iterators;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;

import cz.vutbr.web.css.CSSFactory;
import cz.vutbr.web.css.Declaration;
import cz.vutbr.web.css.NodeData;
import cz.vutbr.web.css.RuleMargin;
import cz.vutbr.web.css.RulePage;
import cz.vutbr.web.css.Selector;
import cz.vutbr.web.css.StyleSheet;
import cz.vutbr.web.css.SupportedCSS;
import cz.vutbr.web.domassign.Analyzer;
import cz.vutbr.web.domassign.SingleMapNodeData;
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

import org.daisy.braille.css.BrailleCSSNodeData;
import org.daisy.braille.css.SupportedBrailleCSS;
import org.daisy.braille.css.SupportedPrintCSS;
import org.daisy.common.xproc.calabash.XProcStepProvider;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;

import static org.daisy.pipeline.braille.Utilities.Strings.join;
import static org.daisy.pipeline.braille.Utilities.Strings.normalizeSpace;

public class ApplyStylesheetProvider implements XProcStepProvider {
	
	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new ApplyStylesheet(runtime, step);
	}
	
	private static SupportedCSS brailleCSS = SupportedBrailleCSS.getInstance();
	private static SupportedCSS printCSS = SupportedPrintCSS.getInstance();
	private static Class<? extends NodeData> brailleNodeDataImpl = BrailleCSSNodeData.class;
	private static Class<? extends NodeData> printNodeDataImpl = SingleMapNodeData.class;
	
	public void setUriResolver(URIResolver resolver) {
		CSSFactory.registerURIResolver(resolver);
	}
	
	public class ApplyStylesheet extends DefaultStep {
	
		private ReadablePipe sourcePipe = null;
		private WritablePipe resultPipe = null;
		private WritablePipe pagesPipe = null;
		
		private ApplyStylesheet(XProcRuntime runtime, XAtomicStep step) {
			super(runtime, step);
		}
	
		@Override
		public void setInput(String port, ReadablePipe pipe) {
			sourcePipe = pipe;
		}
	
		@Override
		public void setOutput(String port, WritablePipe pipe) {
			if (port.equals("result"))
				resultPipe = pipe;
			else if (port.equals("pages"))
				pagesPipe = pipe;
		}
	
		@Override
		public void reset() {
			sourcePipe.resetReader();
			resultPipe.resetWriter();
			pagesPipe.resetWriter();
		}
	
		@Override
		public void run() throws SaxonApiException {
			super.run();
			try {
				XdmNode source = sourcePipe.read();
				Document doc = (Document)DocumentOverNodeInfo.wrap(source.getUnderlyingNode());
				CSSFactory.registerNodeDataInstance(printNodeDataImpl);
				StyleSheet brailleSheet = CSSFactory.getUsedStyles(doc, source.getBaseURI().toURL(), "embossed");
				StyleSheet printSheet = CSSFactory.getUsedStyles(doc, source.getBaseURI().toURL(), "print");
				resultPipe.write((new InlineCSSWriter(doc, brailleSheet, printSheet, runtime)).getResult());
				pagesPipe.write(new CSSPagesWriter(new URI(doc.getBaseURI()), brailleSheet, runtime).getResult()); }
			catch (Exception e) {
				throw new RuntimeException(e); }
		}
	}
	
	private static final String CSS_URI = "http://www.daisy.org/ns/pipeline/braille-css";
	private static final String CSS_PREFIX = "css";
	
	private static final QName _style = new QName("style");
	private static final QName _css_before = new QName(CSS_PREFIX, CSS_URI, "before");
	private static final QName _css_after = new QName(CSS_PREFIX, CSS_URI, "after");
	
	private static class InlineCSSWriter extends TreeWriter {
		
		private final StyleMap brailleStylemap;
		private final StyleMap printStylemap;
		
		public InlineCSSWriter(Document document, StyleSheet brailleStylesheet,
				StyleSheet printStylesheet, XProcRuntime xproc) throws Exception {
			super(xproc);
			CSSFactory.registerSupportedCSS(brailleCSS);
			CSSFactory.registerNodeDataInstance(brailleNodeDataImpl);
			brailleStylemap = new Analyzer(brailleStylesheet).evaluateDOM(document, "embossed", false);
			CSSFactory.registerSupportedCSS(printCSS);
			CSSFactory.registerNodeDataInstance(printNodeDataImpl);
			printStylemap = new Analyzer(printStylesheet).evaluateDOM(document, "print", false);
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
					if ("http://www.w3.org/2000/xmlns/".equals(attr.getNamespaceURI())) {}
					else if (attr.getPrefix() != null)
						addAttribute(new QName(attr.getPrefix(), attr.getNamespaceURI(), attr.getLocalName()), attr.getNodeValue());
					else if ("style".equals(attr.getLocalName())) {}
					else
						addAttribute(new QName(attr.getNamespaceURI(), attr.getLocalName()), attr.getNodeValue()); }
				String style = "";
				NodeData brailleData = brailleStylemap.get((Element)node);
				if (brailleData != null)
					style += normalizeSpace(brailleData);
				NodeData printData = printStylemap.get((Element)node);
				if (printData != null)
					style += normalizeSpace(printData);
				if (style.length() > 0)
					addAttribute(_style, style);
				receiver.startContent();
				NodeData beforeData = brailleStylemap.get((Element)node, Selector.PseudoDeclaration.BEFORE);
				if (beforeData != null) {
					String beforeStyle = normalizeSpace(beforeData);
					if (beforeStyle.length() > 0) {
						addStartElement(_css_before);
						addAttribute(_style, beforeStyle);
						addEndElement(); }}
				for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling())
					traverse(child);
				NodeData afterData = brailleStylemap.get((Element)node, Selector.PseudoDeclaration.AFTER);
				if (afterData != null) {
					String afterStyle = normalizeSpace(afterData);
					if (afterStyle.length() > 0) {
						addStartElement(_css_after);
						addAttribute(_style, afterStyle);
						addEndElement(); }}
				addEndElement(); }
			else if (node.getNodeType() == Node.COMMENT_NODE)
				addComment(node.getNodeValue());
			else if (node.getNodeType() == Node.TEXT_NODE)
				addText(node.getNodeValue());
			else if (node.getNodeType() == Node.PROCESSING_INSTRUCTION_NODE)
				addPI(node.getLocalName(), node.getNodeValue());
			else
				throw new UnsupportedOperationException("Unexpected node type");
		}
		
		public void addStartElement(Element element) {
			NodeInfo inode = ((NodeOverNodeInfo)element).getUnderlyingNodeInfo();
			NamespaceBinding[] inscopeNS = null;
			if (seenRoot)
				inscopeNS = inode.getDeclaredNamespaces(null);
			else {
				List<NamespaceBinding> namespaces = new ArrayList<NamespaceBinding>();
				Iterators.<NamespaceBinding>addAll(namespaces, NamespaceIterator.iterateNamespaces(inode));
				namespaces.add(NamespaceBinding.makeNamespaceBinding(CSS_PREFIX, CSS_URI));
				inscopeNS = Iterables.<NamespaceBinding>toArray(namespaces, NamespaceBinding.class);
				seenRoot = true; }
			receiver.setSystemId(element.getBaseURI());
			addStartElement(new NameOfNode(inode), inode.getSchemaType(), inscopeNS);
		}
	}
	
	private static final QName _css_page = new QName(CSS_PREFIX, CSS_URI, "page");
	private static final QName _css_pages = new QName(CSS_PREFIX, CSS_URI, "pages");
	private static final QName _name = new QName("name");
	private static final QName _position = new QName("position");
	
	private static class CSSPagesWriter extends TreeWriter {
		public CSSPagesWriter(URI base, StyleSheet stylesheet, XProcRuntime xproc) throws Exception {
			super(xproc);
			startDocument(base);
			addStartElement(_css_pages);
			Iterable<RulePage> pages =  Iterables.<RulePage>filter(stylesheet, RulePage.class);
			for (RulePage page : pages) {
				addStartElement(_css_page);
				String name = page.getName();
				String pseudo = page.getPseudo();
				if (name != null) addAttribute(_name, name);
				if (pseudo != null) addAttribute(_position, pseudo);
				String pageStyle = normalizeSpace(join(
						Iterables.<Declaration>filter(page, Declaration.class), " "));
				if (!"".equals(pageStyle))
					addAttribute(_style, pageStyle);
				for (RuleMargin margin : Iterables.<RuleMargin>filter(page, RuleMargin.class)) {
					addStartElement(new QName(CSS_PREFIX, CSS_URI, margin.getMarginArea().value));
					String marginStyle = normalizeSpace(join(margin, " "));
					if (!"".equals(marginStyle))
						addAttribute(_style, marginStyle);
					addEndElement(); }
				addEndElement(); }
			addEndElement();
			endDocument();
		}
	}
}
