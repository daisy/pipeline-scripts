package org.daisy.pipeline.braille.dotify.transform;

import java.util.Map;
import java.net.URI;
import javax.xml.namespace.QName;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableMap;

import static org.daisy.braille.css.Query.parseQuery;
import org.daisy.pipeline.braille.common.Cached;
import static org.daisy.pipeline.braille.common.util.Tuple3;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.common.XProcCSSStyledDocumentTransform;
import org.daisy.pipeline.braille.common.XProcTransform;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.ComponentContext;

@Component(
	name = "org.daisy.pipeline.braille.dotify.transform.DotifyCSSStyledDocumentTransformProvider",
	service = { XProcTransform.Provider.class }
)
public class DotifyCSSStyledDocumentTransformProvider implements XProcTransform.Provider<XProcCSSStyledDocumentTransform> {
	
	private URI href;
	
	@Activate
	private void activate(ComponentContext context, final Map<?,?> properties) {
		href = asURI(context.getBundleContext().getBundle().getEntry("xml/transform/dotify-transform.xpl"));
	}
	
	private Cached<String,XProcCSSStyledDocumentTransform> transforms
		= new Cached<String,XProcCSSStyledDocumentTransform>() {
			public XProcCSSStyledDocumentTransform delegate(final String query) {
				final URI href = DotifyCSSStyledDocumentTransformProvider.this.href;
				Map<String,Optional<String>> q = parseQuery(query);
				boolean match = false;
				if (q.containsKey("dotify-formatter"))
					match = true;
				else if (q.containsKey("formatter"))
					if (q.get("formatter").get().equals("dotify"))
						match = true;
				if (!match)
					return null;
				final Map<String,String> options = ImmutableMap.<String,String>of("query", query);
				return new XProcCSSStyledDocumentTransform() {
					public Tuple3<URI,QName,Map<String,String>> asXProc() {
						return new Tuple3<URI,QName,Map<String,String>>(href, null, options); }}; }};
	
	public Iterable<XProcCSSStyledDocumentTransform> get(String query) {
		return Optional.<XProcCSSStyledDocumentTransform>fromNullable(transforms.get(query)).asSet();
	}
}
