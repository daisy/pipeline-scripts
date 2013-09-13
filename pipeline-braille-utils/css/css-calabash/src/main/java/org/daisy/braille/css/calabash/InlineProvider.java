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
import cz.vutbr.web.css.Term;
import cz.vutbr.web.css.TermIdent;
import cz.vutbr.web.domassign.Analyzer;
import cz.vutbr.web.domassign.DeclarationTransformer;
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

import org.daisy.braille.css.BrailleCSSDeclarationTransformer;
import org.daisy.braille.css.BrailleCSSProperty;
import org.daisy.braille.css.SupportedBrailleCSS;
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
	
	private static SupportedBrailleCSS supportedCSS;
	
	static {
		supportedCSS = new SupportedBrailleCSS();
		// FIXME: SupportedCSS can be set only once! must be done *before* NodeData is initialized
		CSSFactory.registerSupportedCSS(supportedCSS);
		// FIXME: DeclarationTransformer can be set only once! must be done *before* NodeData is initialized
		CSSFactory.registerDeclarationTransformer(new BrailleCSSDeclarationTransformer());
	}
	
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
				resultPipe.write((new InlineCSSWriter(doc, runtime)).getResult()); }
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
		                       XProcRuntime xproc) throws Exception {
			super(xproc);
			
			URI baseURI = new URI(document.getBaseURI());
			
			// media embossed
			supportedCSS.setSupportedMedia("embossed");
			StyleSheet brailleStyleSheet = CSSFactory.getUsedStyles(document, baseURI.toURL(), "embossed");
			brailleStylemap = new Analyzer(brailleStyleSheet).evaluateDOM(document, "embossed", false);
			
			// media print
			supportedCSS.setSupportedMedia("print");
			StyleSheet printStyleSheet = CSSFactory.getUsedStyles(document, baseURI.toURL(), "print");
			printStylemap = new Analyzer(printStyleSheet).evaluateDOM(document, "print", false);
			
			pages = new HashMap<String,RulePage>();
			for (RulePage page : Iterables.<RulePage>filter(brailleStyleSheet, RulePage.class))
				pages.put(Objects.firstNonNull(page.getName(), "auto"), page);
			
			startDocument(baseURI);
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
					insertStyle(style, brailleData);
				NodeData printData = printStylemap.get((Element)node);
				if (printData != null)
					insertStyle(style, printData);
				NodeData beforeData = brailleStylemap.get((Element)node, Selector.PseudoDeclaration.BEFORE);
				if (beforeData != null)
					insertPseudoStyle(style, beforeData, Selector.PseudoDeclaration.BEFORE);
				NodeData afterData = brailleStylemap.get((Element)node, Selector.PseudoDeclaration.AFTER);
				if (afterData != null)
					insertPseudoStyle(style, afterData, Selector.PseudoDeclaration.AFTER);
				BrailleCSSProperty.Page pageProperty = brailleData.<BrailleCSSProperty.Page>getProperty("page", false);
				if (pageProperty != null) {
					RulePage page;
					if (pageProperty == BrailleCSSProperty.Page.identifier)
						page = pages.get(brailleData.<TermIdent>getValue(TermIdent.class, "page", false).getValue());
					else
						page = pages.get(pageProperty.toString());
					if (page != null)
						insertPageStyle(style, page, pages.get("auto")); }
				else if (isRoot) {
					RulePage page = pages.get("auto");
					if (page != null)
						insertPageStyle(style, page, null); }
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
	
	private static void insertStyle(StringBuilder builder, NodeData nodeData) {
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
	
	private static void insertPseudoStyle(StringBuilder builder, NodeData nodeData, Selector.PseudoDeclaration decl) {
		if (builder.length() > 0 && !builder.toString().endsWith("} ")) {
			builder.insert(0, "{ ");
			builder.append("} "); }
		builder.append(decl.isPseudoElement() ? "::" : ":").append(decl.value()).append(" { ");
		insertStyle(builder, nodeData);
		builder.append("} ");
	}
	
	private static void insertPageStyle(StringBuilder builder, RulePage rulePage, RulePage inheritFrom) {
		if (builder.length() > 0 && !builder.toString().endsWith("} ")) {
			builder.insert(0, "{ ");
			builder.append("} "); }
		builder.append("@page ");
		String pseudo = rulePage.getPseudo();
		if (pseudo != null && !"".equals(pseudo))
			builder.append(":").append(pseudo).append(" ");
		builder.append("{ ");
		List<String> seen = new ArrayList<String>();
		for (Declaration decl : Iterables.<Declaration>filter(rulePage, Declaration.class)) {
			seen.add(decl.getProperty());
			insertDeclaration(builder, decl); }
		if (inheritFrom != null)
			for (Declaration decl : Iterables.<Declaration>filter(inheritFrom, Declaration.class))
				if (!seen.contains(decl.getProperty()))
					insertDeclaration(builder, decl);
		seen.clear();
		for (RuleMargin margin : Iterables.<RuleMargin>filter(rulePage, RuleMargin.class)) {
			seen.add(margin.getMarginArea().value);
			insertMarginStyle(builder, margin); }
		if (inheritFrom != null)
			for (RuleMargin margin : Iterables.<RuleMargin>filter(inheritFrom, RuleMargin.class))
				if (!seen.contains(margin.getMarginArea().value))
					insertMarginStyle(builder, margin);
		builder.append("} ");
	}
	
	private static void insertMarginStyle(StringBuilder builder, RuleMargin ruleMargin) {
		builder.append("@").append(ruleMargin.getMarginArea().value).append(" { ");
		for (Declaration decl : ruleMargin)
			insertDeclaration(builder, decl);
		builder.append("} ");
	}
	
	private static void insertDeclaration(StringBuilder builder, Declaration decl) {
		builder.append(normalizeProperty(decl.getProperty())).append(": ").append(join(decl, "")).append("; ");
	}
	
	private static String normalizeProperty(String property) {
		if (property.startsWith("-brl-"))
			return property.substring(5);
		return property;
	}
}
