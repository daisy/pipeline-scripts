package org.daisy.pipeline.braille.dotify.transform;

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
import org.daisy.pipeline.braille.dotify.DotifyTranslator;
import org.daisy.pipeline.braille.dotify.DotifyTranslatorProvider;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.osgi.service.component.ComponentContext;

@Component(
	name = "org.daisy.pipeline.braille.dotify.transform.DotifyCSSBlockTransformProvider",
	service = { XProcTransform.Provider.class, XProcCSSBlockTransform.Provider.class }
)
public class DotifyCSSBlockTransformProvider implements XProcCSSBlockTransform.Provider {
	
	private URI href;
	
	@Activate
	private void activate(ComponentContext context, final Map<?,?> properties) {
		href = asURI(context.getBundleContext().getBundle().getEntry("xml/transform/dotify-block-translate.xpl"));
	}
	
	/**
	 * Recognized features:
	 *
	 * - translator: Will only match if the value is `dotify'.
	 * - locale: If present the value will be used instead of any xml:lang attributes.
	 *
	 * Other features are used for finding sub-transformers of type DotifyTranslator.
	 */
	public Iterable<XProcCSSBlockTransform> get(String query) {
		return Optional.<XProcCSSBlockTransform>fromNullable(transforms.get(query)).asSet();
	}
	
	private Cached<String,XProcCSSBlockTransform> transforms
	= new Cached<String,XProcCSSBlockTransform>() {
		public XProcCSSBlockTransform delegate(String query) {
			final URI href = DotifyCSSBlockTransformProvider.this.href;
			Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
			Optional<String> o;
			if ((o = q.remove("translator")) != null)
				if (!o.get().equals("dotify"))
					return null;
			String newQuery = serializeQuery(q);
			if (!dotifyTranslatorProvider.get(newQuery).iterator().hasNext())
				return null;
			final Map<String,String> options = ImmutableMap.<String,String>of("query", newQuery);
			return new XProcCSSBlockTransform() {
				public Tuple3<URI,QName,Map<String,String>> asXProc() {
					return new Tuple3<URI,QName,Map<String,String>>(href, null, options); }};
		}
	};
	
	@Reference(
		name = "DotifyTranslatorProvider",
		unbind = "unbindDotifyTranslatorProvider",
		service = DotifyTranslatorProvider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	protected void bindDotifyTranslatorProvider(DotifyTranslatorProvider provider) {
		dotifyTranslatorProviders.add(provider);
	}
	
	protected void unbindDotifyTranslatorProvider(DotifyTranslatorProvider provider) {
		dotifyTranslatorProviders.remove(provider);
		dotifyTranslatorProvider.invalidateCache();
	}
	
	private List<DotifyTranslatorProvider> dotifyTranslatorProviders = new ArrayList<DotifyTranslatorProvider>();
	private CachedProvider<String,DotifyTranslator> dotifyTranslatorProvider
	= CachedProvider.<String,DotifyTranslator>newInstance(
		DispatchingProvider.<String,DotifyTranslator>newInstance(dotifyTranslatorProviders));
	
}
