package org.daisy.pipeline.braille.liblouis.transform;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.net.URI;
import javax.xml.namespace.QName;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableMap;

import static org.daisy.braille.css.Query.parseQuery;
import static org.daisy.braille.css.Query.serializeQuery;
import org.daisy.pipeline.braille.common.Cached;
import static org.daisy.pipeline.braille.common.util.Tuple3;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.common.Provider;
import org.daisy.pipeline.braille.common.XProcCSSBlockTransform;
import org.daisy.pipeline.braille.common.XProcCSSStyledDocumentTransform;
import org.daisy.pipeline.braille.common.XProcTransform;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.osgi.service.component.ComponentContext;

@Component(
	name = "org.daisy.pipeline.braille.liblouis.transform.LiblouisCSSStyledDocumentTransformProvider",
	service = { XProcTransform.Provider.class }
)
public class LiblouisCSSStyledDocumentTransformProvider implements XProcTransform.Provider<XProcCSSStyledDocumentTransform> {
	
	private URI href;
	
	@Activate
	private void activate(ComponentContext context, final Map<?,?> properties) {
		href = asURI(context.getBundleContext().getBundle().getEntry("xml/transform/liblouis-transform.xpl"));
	}
	
	/**
	 * Recognized features:
	 *
	 * - formatter: Will only match if the value is `liblouis'.
	 *
	 * Other features are used for finding sub-transformers of type CSSBlockTransform.
	 */
	public Iterable<XProcCSSStyledDocumentTransform> get(String query) {
		return Optional.<XProcCSSStyledDocumentTransform>fromNullable(transforms.get(query)).asSet();
	}
	
	private Cached<String,XProcCSSStyledDocumentTransform> transforms
	= new Cached<String,XProcCSSStyledDocumentTransform>() {
		public XProcCSSStyledDocumentTransform delegate(final String query) {
			final URI href = LiblouisCSSStyledDocumentTransformProvider.this.href;
			Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
			Optional<String> o;
			if ((o = q.remove("formatter")) != null)
				if (!o.get().equals("liblouis"))
					return null;
			String newQuery = serializeQuery(q);
			if (!xprocCSSBlockTransformProvider.get(newQuery).iterator().hasNext())
				return null;
			final Map<String,String> options = ImmutableMap.<String,String>of("query", newQuery);
			return new XProcCSSStyledDocumentTransform() {
				public Tuple3<URI,QName,Map<String,String>> asXProc() {
					return new Tuple3<URI,QName,Map<String,String>>(href, null, options); }};
		}
	};
	
	@Reference(
		name = "XProcCSSBlockTransformProvider",
		unbind = "unbindXProcCSSBlockTransformProvider",
		service = XProcCSSBlockTransform.Provider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	public void bindXProcCSSBlockTransformProvider(XProcCSSBlockTransform.Provider provider) {
		xprocCSSBlockTransformProviders.add(provider);
	}
	
	public void unbindXProcCSSBlockTransformProvider(XProcCSSBlockTransform.Provider provider) {
		xprocCSSBlockTransformProviders.remove(provider);
		xprocCSSBlockTransformProvider.invalidateCache();
	}
		
	private List<Provider<String,XProcCSSBlockTransform>> xprocCSSBlockTransformProviders
	= new ArrayList<Provider<String,XProcCSSBlockTransform>>();
		
	private CachedProvider<String,XProcCSSBlockTransform> xprocCSSBlockTransformProvider
	= CachedProvider.<String,XProcCSSBlockTransform>newInstance(
		DispatchingProvider.<String,XProcCSSBlockTransform>newInstance(xprocCSSBlockTransformProviders));
	
}
