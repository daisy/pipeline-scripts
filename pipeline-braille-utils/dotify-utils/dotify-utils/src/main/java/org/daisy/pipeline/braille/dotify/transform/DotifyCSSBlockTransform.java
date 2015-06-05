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
import org.daisy.pipeline.braille.common.CSSBlockTransform;
import org.daisy.pipeline.braille.common.XProcTransform;
import org.daisy.pipeline.braille.dotify.DotifyTranslator;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.osgi.service.component.ComponentContext;

public interface DotifyCSSBlockTransform extends XProcTransform, CSSBlockTransform {
	
	@Component(
		name = "org.daisy.pipeline.braille.dotify.transform.DotifyCSSBlockTransform.Provider",
		service = {
			XProcTransform.Provider.class,
			CSSBlockTransform.Provider.class
		}
	)
	public class Provider implements XProcTransform.Provider<DotifyCSSBlockTransform>, CSSBlockTransform.Provider<DotifyCSSBlockTransform> {
		
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
		public Iterable<DotifyCSSBlockTransform> get(String query) {
			return Optional.<DotifyCSSBlockTransform>fromNullable(transforms.get(query)).asSet();
		}
		
		private Cached<String,DotifyCSSBlockTransform> transforms
		= new Cached<String,DotifyCSSBlockTransform>() {
			public DotifyCSSBlockTransform delegate(String query) {
				final URI href = Provider.this.href;
				Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
				Optional<String> o;
				if ((o = q.remove("translator")) != null)
					if (!o.get().equals("dotify"))
						return null;
				String newQuery = serializeQuery(q);
				if (!dotifyTranslatorProvider.get(newQuery).iterator().hasNext())
					return null;
				final Map<String,String> options = ImmutableMap.<String,String>of("query", newQuery);
				return new DotifyCSSBlockTransform() {
					public Tuple3<URI,QName,Map<String,String>> asXProc() {
						return new Tuple3<URI,QName,Map<String,String>>(href, null, options); }};
			}
		};
		
		@Reference(
			name = "DotifyTranslatorProvider",
			unbind = "unbindDotifyTranslatorProvider",
			service = DotifyTranslator.Provider.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		protected void bindDotifyTranslatorProvider(DotifyTranslator.Provider provider) {
			dotifyTranslatorProviders.add(provider);
		}
		
		protected void unbindDotifyTranslatorProvider(DotifyTranslator.Provider provider) {
			dotifyTranslatorProviders.remove(provider);
			dotifyTranslatorProvider.invalidateCache();
		}
		
		private List<DotifyTranslator.Provider> dotifyTranslatorProviders = new ArrayList<DotifyTranslator.Provider>();
		private CachedProvider<String,DotifyTranslator> dotifyTranslatorProvider
		= CachedProvider.<String,DotifyTranslator>newInstance(
			DispatchingProvider.<String,DotifyTranslator>newInstance(dotifyTranslatorProviders));
	
	}
}
