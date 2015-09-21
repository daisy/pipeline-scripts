package org.daisy.pipeline.braille.css.calabash.impl;

import java.io.InputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.StringTokenizer;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import com.google.common.base.Function;
import static com.google.common.base.Strings.emptyToNull;
import com.google.common.base.Objects;
import static com.google.common.collect.Iterables.filter;
import static com.google.common.collect.Iterables.toArray;
import static com.google.common.collect.Iterators.addAll;

import com.xmlcalabash.core.XProcException;
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
import cz.vutbr.web.css.MediaSpec;
import cz.vutbr.web.css.NetworkProcessor;
import cz.vutbr.web.css.NodeData;
import cz.vutbr.web.css.Rule;
import cz.vutbr.web.css.RuleMargin;
import cz.vutbr.web.css.RulePage;
import cz.vutbr.web.css.Selector;
import cz.vutbr.web.css.StyleSheet;
import cz.vutbr.web.css.SupportedCSS;
import cz.vutbr.web.css.Term;
import cz.vutbr.web.css.TermIdent;
import cz.vutbr.web.css.TermInteger;
import cz.vutbr.web.csskit.antlr.CSSParserFactory;
import cz.vutbr.web.csskit.antlr.CSSParserFactory.SourceType;
import cz.vutbr.web.csskit.DefaultNetworkProcessor;
import cz.vutbr.web.csskit.RulePageImpl;
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
import org.daisy.braille.css.BrailleCSSParserFactory;
import org.daisy.braille.css.BrailleCSSProperty;
import org.daisy.braille.css.SupportedBrailleCSS;
import org.daisy.common.xproc.calabash.XProcStepProvider;
import static org.daisy.pipeline.braille.common.util.Strings.join;
import static org.daisy.pipeline.braille.common.util.Strings.normalizeSpace;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import static org.daisy.pipeline.braille.common.util.URLs.asURL;
import org.daisy.pipeline.braille.css.SupportedPrintCSS;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CSSInlineStep extends DefaultStep {
	
	private ReadablePipe sourcePipe = null;
	private WritablePipe resultPipe = null;
	private NetworkProcessor network = null;
	
	private static final QName _default_stylesheet = new QName("default-stylesheet");
	
	private CSSInlineStep(XProcRuntime runtime, XAtomicStep step, final URIResolver resolver) {
		super(runtime, step);
		network = new DefaultNetworkProcessor() {
			@Override
			public InputStream fetch(URL url) throws IOException {
				try {
					if (url != null) {
						Source resolved = resolver.resolve(url.toString(), "");
						if (resolved != null) {
							if (resolved instanceof StreamSource)
								return ((StreamSource)resolved).getInputStream();
							else
								url = new URL(resolved.getSystemId());
						}
					}
				} catch (TransformerException e) {
				} catch (MalformedURLException e) {
				}
				return super.fetch(url);
			}
		};
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
			URI base = asURI(doc.getBaseURI());
			URL[] defaultSheets; {
				StringTokenizer t = new StringTokenizer(getOption(_default_stylesheet, ""));
				ArrayList<URL> l = new ArrayList<URL>();
				while (t.hasMoreTokens())
					l.add(asURL(base.resolve(asURI(t.nextToken()))));
				defaultSheets = toArray(l, URL.class);
			}
			resultPipe.write((new InlineCSSWriter(doc, runtime, defaultSheets)).getResult()); }
		catch (Exception e) {
			logger.error("css:inline failed", e);
			throw new XProcException(step.getNode(), e); }
	}
	
	@Component(
		name = "css:inline",
		service = { XProcStepProvider.class },
		property = { "type:String={http://www.daisy.org/ns/pipeline/braille-css}inline" }
	)
	public static class Provider implements XProcStepProvider {
		
		private URIResolver resolver;
		
		@Override
		public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
			return new CSSInlineStep(runtime, step, resolver);
		}
		
		@Reference(
			name = "URIResolver",
			unbind = "-",
			service = URIResolver.class,
			cardinality = ReferenceCardinality.MANDATORY,
			policy = ReferencePolicy.STATIC
		)
		public void setUriResolver(URIResolver resolver) {
			this.resolver = resolver;
		}
	}
	
	private static final QName _style = new QName("style");
	
	private static final SupportedCSS brailleCSS = SupportedBrailleCSS.getInstance();
	private static final SupportedCSS printCSS = SupportedPrintCSS.getInstance();
	private static DeclarationTransformer brailleDeclarationTransformer;
	private static DeclarationTransformer printDeclarationTransformer;
	
	static {
		CSSFactory.registerSupportedCSS(brailleCSS);
		brailleDeclarationTransformer = new BrailleCSSDeclarationTransformer();
		CSSFactory.registerSupportedCSS(printCSS);
		printDeclarationTransformer = new DeclarationTransformer() {};
	}
	
	private class InlineCSSWriter extends TreeWriter {
		
		private final StyleMap brailleStylemap;
		private final StyleMap printStylemap;
		private final Map<String,Map<String,RulePage>> pageRules;
		
		private final CSSParserFactory parserFactory = new BrailleCSSParserFactory();
		
		public InlineCSSWriter(Document document,
		                       XProcRuntime xproc,
		                       URL[] defaultSheets) throws Exception {
			super(xproc);
			
			CSSFactory.registerCSSParserFactory(parserFactory);
			
			URI baseURI = new URI(document.getBaseURI());
			
			// media embossed
			
			CSSFactory.registerSupportedCSS(brailleCSS);
			CSSFactory.registerDeclarationTransformer(brailleDeclarationTransformer);
			StyleSheet brailleStyle = (StyleSheet)CSSFactory.getRuleFactory().createStyleSheet().unlock();
			if (defaultSheets != null)
				for (URL sheet : defaultSheets)
					brailleStyle = parserFactory.append(sheet, network, null, SourceType.URL, brailleStyle, sheet);
			brailleStyle = CSSFactory.getUsedStyles(document, null, asURL(baseURI), new MediaSpec("embossed"), network, brailleStyle);
			brailleStylemap = new Analyzer(brailleStyle).evaluateDOM(document, "embossed", false);
			
			// media print
			CSSFactory.registerSupportedCSS(printCSS);
			CSSFactory.registerDeclarationTransformer(printDeclarationTransformer);
			StyleSheet printStyle = (StyleSheet)CSSFactory.getRuleFactory().createStyleSheet().unlock();
			if (defaultSheets != null)
				for (URL sheet : defaultSheets)
					printStyle = parserFactory.append(sheet, network, null, SourceType.URL, printStyle, sheet);
			printStyle = CSSFactory.getUsedStyles(document, null, asURL(baseURI), new MediaSpec("print"), network, printStyle);
			printStylemap = new Analyzer(printStyle).evaluateDOM(document, "print", false);
			
			pageRules = new HashMap<String,Map<String,RulePage>>();
			for (RulePage r : filter(brailleStyle, RulePage.class)) {
				String name = Objects.firstNonNull(r.getName(), "auto");
				String pseudo = Objects.firstNonNull(r.getPseudo(), "");
				Map<String,RulePage> pageRule = pageRules.get(name);
				if (pageRule == null) {
					pageRule = new HashMap<String,RulePage>();
					pageRules.put(name, pageRule); }
				pageRule.put(pseudo, r);
			}
			
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
				BrailleCSSProperty.Page pageProperty = null;
				if (brailleData != null)
					pageProperty = brailleData.<BrailleCSSProperty.Page>getProperty("page", false);
				if (pageProperty != null) {
					String name;
					if (pageProperty == BrailleCSSProperty.Page.identifier)
						name = brailleData.<TermIdent>getValue(TermIdent.class, "page", false).getValue();
					else
						name = pageProperty.toString();
					Map<String,RulePage> pageRule = getPageRule(name, pageRules);
					if (pageRule != null)
						insertPageStyle(style, pageRule); }
				else if (isRoot) {
					Map<String,RulePage> pageRule = getPageRule("auto", pageRules);
					if (pageRule != null)
						insertPageStyle(style, pageRule); }
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
				addAll(namespaces, NamespaceIterator.iterateNamespaces(inode));
				inscopeNS = toArray(namespaces, NamespaceBinding.class);
				seenRoot = true; }
			receiver.setSystemId(element.getBaseURI());
			addStartElement(new NameOfNode(inode), inode.getSchemaType(), inscopeNS);
		}
	}
	
	private static Function<Object,String> termToString = new Function<Object,String>() {
		public String apply(Object term) {
			if (term instanceof TermInteger)
				return String.valueOf(((TermInteger)term).getIntValue());
			else
				return String.valueOf(term);
		}
	};
	
	private static void insertStyle(StringBuilder builder, NodeData nodeData) {
		List<String> keys = new ArrayList<String>(nodeData.getPropertyNames());
		keys.remove("page");
		Collections.sort(keys);
		for(String key : keys) {
			builder.append(key).append(": ");
			Term<?> value = nodeData.getValue(key, true);
			if (value != null)
				builder.append(termToString.apply(value));
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
	
	private static void insertPageStyle(StringBuilder builder, Map<String,RulePage> pageRule) {
		for (RulePage r : pageRule.values())
			insertPageStyle(builder, r);
	}
	
	private static void insertPageStyle(StringBuilder builder, RulePage pageRule) {
		if (builder.length() > 0 && !builder.toString().endsWith("} ")) {
			builder.insert(0, "{ ");
			builder.append("} "); }
		builder.append("@page");
		String pseudo = pageRule.getPseudo();
		if (pseudo != null && !"".equals(pseudo))
			builder.append(":").append(pseudo);
		builder.append(" { ");
		for (Declaration decl : filter(pageRule, Declaration.class))
			insertDeclaration(builder, decl);
		for (RuleMargin margin : filter(pageRule, RuleMargin.class))
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
		builder.append(decl.getProperty()).append(": ").append(join(decl, " ", termToString)).append("; ");
	}
	
	private static Map<String,RulePage> getPageRule(String name, Map<String,Map<String,RulePage>> pageRules) {
		Map<String,RulePage> auto = pageRules.get("auto");
		if (name.equals("auto"))
			return auto;
		Map<String,RulePage> named = pageRules.get(name);
		if (named == null)
			return auto;
		Map<String,RulePage> result = new HashMap<String,RulePage>();
		List<RulePage> from;
		RulePage r;
		from = new ArrayList<RulePage>();
		r = named.get("");
		if (r != null) from.add(r);
		if (auto != null) {
			r = auto.get("");
			if (r != null) from.add(r); }
		if (from.size() > 0)
			result.put("", makePageRule(name, null, from));
		for (String pseudo : new String[]{"left", "right"}) {
			if (named.containsKey(pseudo) || auto != null && auto.containsKey(pseudo)) {
				from = new ArrayList<RulePage>();
				r = named.get(pseudo);
				if (r != null) from.add(r);
				r = named.get("");
				if (r != null) from.add(r);
				if (auto != null) {
					r = auto.get(pseudo);
					if (r != null) from.add(r);
					r = auto.get("");
					if (r != null) from.add(r); }
				if (from.size() > 0)
					result.put(pseudo, makePageRule(name, pseudo, from)); }}
		return result;
	}
	
	private static RulePage makePageRule(String name, String pseudo, List<RulePage> from) {
		RulePage pageRule = CSSFactory.getRuleFactory().createPage().setName(name).setPseudo(pseudo);
		Set<String> properties = new HashSet<String>();
		Map<String,RuleMargin> marginRules = new HashMap<String,RuleMargin>();
		for (RulePage f : from)
			for (Rule<?> r : f)
				if (r instanceof Declaration) {
					Declaration d = (Declaration)r;
					String property = d.getProperty();
					if (getDeclaration(pageRule, property) == null)
						pageRule.add(r); }
				else if (r instanceof RuleMargin) {
					RuleMargin m = (RuleMargin)r;
					String marginArea = m.getMarginArea().value;
					RuleMargin marginRule = getRuleMargin(pageRule, marginArea);
					if (marginRule == null) {
						marginRule = CSSFactory.getRuleFactory().createMargin(marginArea);
						pageRule.add(marginRule);
						marginRule.replaceAll(m); }
					else
						for (Declaration d : m)
							if (getDeclaration(marginRule, d.getProperty()) == null)
								marginRule.add(d); }
		return pageRule;
	}
	
	private static Declaration getDeclaration(Collection<? extends Rule<?>> rule, String property) {
		for (Declaration d : filter(rule, Declaration.class))
			if (d.getProperty().equals(property))
				return d;
		return null;
	}
	
	private static RuleMargin getRuleMargin(Collection<? extends Rule<?>> rule, String marginArea) {
		for (RuleMargin m : filter(rule, RuleMargin.class))
			if (m.getMarginArea().value.equals(marginArea))
				return m;
		return null;
	}
	
	private static final Logger logger = LoggerFactory.getLogger(CSSInlineStep.class);
	
}
