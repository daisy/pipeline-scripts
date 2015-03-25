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
import org.daisy.pipeline.braille.common.XProcTransform;
import org.daisy.pipeline.braille.common.XProcCSSBlockTransform;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator;
import org.daisy.pipeline.braille.liblouis.Liblouis;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.osgi.service.component.ComponentContext;

@Component(
	name = "org.daisy.pipeline.braille.liblouis.transform.LiblouisCSSBlockTransformProvider",
	service = { XProcTransform.Provider.class, XProcCSSBlockTransform.Provider.class }
)
public class LiblouisCSSBlockTransformProvider implements XProcCSSBlockTransform.Provider {
	
	private URI href;
	
	@Activate
	private void activate(ComponentContext context, final Map<?,?> properties) {
		href = asURI(context.getBundleContext().getBundle().getEntry("xml/transform/liblouis-block-translate.xpl"));
	}
	
	/**
	 * Recognized features:
	 *
	 * - translator: Will only match if the value is `liblouis'.
	 * - locale: If present the value will be used instead of any xml:lang attributes.
	 *
	 * Other features are used for finding sub-transformers of type LiblouisTranslator.
	 */
	public Iterable<XProcCSSBlockTransform> get(String query) {
		return Optional.<XProcCSSBlockTransform>fromNullable(transforms.get(query)).asSet();
	}
	
	private Cached<String,XProcCSSBlockTransform> transforms
	= new Cached<String,XProcCSSBlockTransform>() {
		public XProcCSSBlockTransform delegate(String query) {
			final URI href = LiblouisCSSBlockTransformProvider.this.href;
			Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
			Optional<String> o;
			if ((o = q.remove("translator")) != null)
				if (!o.get().equals("liblouis"))
					return null;
			String newQuery = serializeQuery(q);
			if (!liblouisTranslatorProvider.get(newQuery).iterator().hasNext())
				return null;
			final Map<String,String> options = ImmutableMap.<String,String>of("query", newQuery);
			return new XProcCSSBlockTransform() {
				public Tuple3<URI,QName,Map<String,String>> asXProc() {
					return new Tuple3<URI,QName,Map<String,String>>(href, null, options); }};
		}
	};
	
	@Reference(
		name = "Liblouis",
		unbind = "unbindLiblouis",
		service = Liblouis.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	protected void bindLiblouis(Liblouis liblouis) {
		liblouisTranslatorProviders.add(liblouis);
	}
	
	protected void unbindLiblouis(Liblouis liblouis) {
		liblouisTranslatorProviders.remove(liblouis);
		liblouisTranslatorProvider.invalidateCache();
	}
	
	private List<Liblouis> liblouisTranslatorProviders = new ArrayList<Liblouis>();
	private CachedProvider<String,LiblouisTranslator> liblouisTranslatorProvider
	= CachedProvider.<String,LiblouisTranslator>newInstance(
		DispatchingProvider.<String,LiblouisTranslator>newInstance(liblouisTranslatorProviders));
}
