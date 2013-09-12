package org.daisy.braille.css.calabash;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.transform.URIResolver;

import com.google.common.base.Objects;
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
import cz.vutbr.web.css.CSSProperty;
import cz.vutbr.web.css.Declaration;
import cz.vutbr.web.css.NodeData;
import cz.vutbr.web.css.RuleMargin;
import cz.vutbr.web.css.RulePage;
import cz.vutbr.web.css.Selector;
import cz.vutbr.web.css.StyleSheet;
import cz.vutbr.web.css.SupportedCSS;
import cz.vutbr.web.css.Term;
import cz.vutbr.web.css.TermIdent;
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
import org.daisy.braille.css.BrailleCSSProperty;
import org.daisy.braille.css.SupportedBrailleCSS;
import org.daisy.braille.css.SupportedPrintCSS;
import org.daisy.common.xproc.calabash.XProcStepProvider;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;

import static org.daisy.pipeline.braille.Utilities.Strings.join;
import static org.daisy.pipeline.braille.Utilities.Strings.normalizeSpace;

public class InlineProvider implements XProcStepProvider {
	
	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new Inline(runtime, step);
	}
	
	private static SupportedCSS brailleCSS = SupportedBrailleCSS.getInstance();
	private static SupportedCSS printCSS = SupportedPrintCSS.getInstance();
	private static Class<? extends NodeData> brailleNodeDataImpl = BrailleCSSNodeData.class;
	private static Class<? extends NodeData> printNodeDataImpl = SingleMapNodeData.class;
	
	public void setUriResolver(URIResolver resolver) {
		CSSFactory.registerURIResolver(resolver);
	}
	
	public class Inline extends DefaultStep {
	
		private ReadablePipe sourcePipe = null;
		private WritablePipe resultPipe = null;
		
		private Inline(XProcRuntime runtime, XAtomicStep step) {
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
				CSSFactory.registerNodeDataInstance(printNodeDataImpl);
				StyleSheet brailleSheet = CSSFactory.getUsedStyles(doc, source.getBaseURI().toURL(), "embossed");
				StyleSheet printSheet = CSSFactory.getUsedStyles(doc, source.getBaseURI().toURL(), "print");
				resultPipe.write((new InlineCSSWriter(doc, brailleSheet, printSheet, runtime)).getResult()); }
			catch (Exception e) {
				throw new RuntimeException(e); }
		}
	}
	
	private static final QName _style = new QName("style");
	
	private static class InlineCSSWriter extends TreeWriter {
		
		private final StyleMap brailleStylemap;
		private final StyleMap printStylemap;
		private final Map<String,RulePage> pages;
		
		public InlineCSSWriter(Document document,
		                       StyleSheet brailleStylesheet,
		                       StyleSheet printStylesheet,
		                       XProcRuntime xproc) throws Exception {
			super(xproc);
			CSSFactory.registerSupportedCSS(brailleCSS);
			CSSFactory.registerNodeDataInstance(brailleNodeDataImpl);
			brailleStylemap = new Analyzer(brailleStylesheet).evaluateDOM(document, "embossed", false);
			CSSFactory.registerSupportedCSS(printCSS);
			CSSFactory.registerNodeDataInstance(printNodeDataImpl);
			printStylemap = new Analyzer(printStylesheet).evaluateDOM(document, "print", false);
			pages = new HashMap<String,RulePage>();
			for (RulePage page : Iterables.<RulePage>filter(brailleStylesheet, RulePage.class))
				pages.put(Objects.firstNonNull(page.getName(), "auto"), page);
			startDocument(new URI(document.getBaseURI()));
			traverse(document.getDocumentElement());
			endDocument();
		}
		
		private void traverse(Node node) throws XPathException, URISyntaxException {
			
			if (node.getNodeType() == Node.ELEMENT_NODE) {
				boolean isRoot = !seenRoot;
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
				StringBuilder style = new StringBuilder();
				NodeData brailleData = brailleStylemap.get((Element)node);
				if (brailleData != null)
					inlineStyle(style, brailleData);
				NodeData printData = printStylemap.get((Element)node);
				if (printData != null)
					inlineStyle(style, printData);
				NodeData beforeData = brailleStylemap.get((Element)node, Selector.PseudoDeclaration.BEFORE);
				if (beforeData != null)
					inlinePseudoStyle(style, beforeData, Selector.PseudoDeclaration.BEFORE);
				NodeData afterData = brailleStylemap.get((Element)node, Selector.PseudoDeclaration.AFTER);
				if (afterData != null)
					inlinePseudoStyle(style, afterData, Selector.PseudoDeclaration.AFTER);
				BrailleCSSProperty.Page pageProperty = brailleData.<BrailleCSSProperty.Page>getProperty("page", false);
				if (pageProperty != null) {
					RulePage page;
					if (pageProperty == BrailleCSSProperty.Page.identifier)
						page = pages.get(brailleData.<TermIdent>getValue(TermIdent.class, "page", false).getValue());
					else
						page = pages.get(pageProperty.toString());
					if (page != null)
						inlinePageStyle(style, page, pages.get("auto")); }
				else if (isRoot) {
					RulePage page = pages.get("auto");
					if (page != null)
						inlinePageStyle(style, page, null); }
				if (normalizeSpace(style).length() > 0) {
					addAttribute(_style, style.toString().trim()); }
				receiver.startContent();
				for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling())
					traverse(child);
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
				inscopeNS = Iterables.<NamespaceBinding>toArray(namespaces, NamespaceBinding.class);
				seenRoot = true; }
			receiver.setSystemId(element.getBaseURI());
			addStartElement(new NameOfNode(inode), inode.getSchemaType(), inscopeNS);
		}
	}
	
	private static void inlineStyle(StringBuilder builder, NodeData nodeData) {
		List<String> keys = new ArrayList<String>(nodeData.getPropertyNames());
		keys.remove("page");
		Collections.sort(keys);
		for(String key : keys) {
			builder.append(normalizeProperty(key)).append(": ");
			Term<?> value = nodeData.getValue(key, true);
			if (value != null)
				builder.append(value.toString());
			else {
				CSSProperty prop = nodeData.getProperty(key);
				builder.append(prop); }
			builder.append("; "); }
	}
	
	private static void inlinePseudoStyle(StringBuilder builder, NodeData nodeData, Selector.PseudoDeclaration decl) {
		if (builder.length() > 0 && builder.charAt(0) != '{') {
			builder.insert(0, "{ ");
			builder.append("} "); }
		builder.append(decl.isPseudoElement() ? "::" : ":").append(decl.value()).append(" { ");
		inlineStyle(builder, nodeData);
		builder.append("} ");
	}
	
	private static void inlinePageStyle(StringBuilder builder, RulePage rulePage, RulePage inheritFrom) {
		if (builder.length() > 0 && builder.charAt(0) != '{') {
			builder.insert(0, "{ ");
			builder.append("} "); }
		builder.append("@page ");
		String pseudo = rulePage.getPseudo();
		if (pseudo != null && !"".equals(pseudo))
			builder.append(":").append(pseudo).append(" ");
		builder.append("{ ");
		for (Declaration decl : Iterables.<Declaration>filter(rulePage, Declaration.class))
			builder.append(normalizeProperty(decl.getProperty())).append(": ").append(join(decl, " ")).append("; ");
		for (RuleMargin margin : Iterables.<RuleMargin>filter(rulePage, RuleMargin.class)) {
			builder.append("@").append(margin.getMarginArea().value).append(" { ");
			for (Declaration decl : margin)
				builder.append(normalizeProperty(decl.getProperty())).append(": ").append(join(decl, " ")).append("; ");
			builder.append("} "); }
		builder.append("} ");
	}
	
	private static String normalizeProperty(String property) {
		if (property.startsWith("-brl-"))
			return property.substring(5);
		return property;
	}
}
