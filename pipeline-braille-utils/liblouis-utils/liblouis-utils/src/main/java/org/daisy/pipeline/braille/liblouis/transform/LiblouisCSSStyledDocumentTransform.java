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
import org.daisy.pipeline.braille.common.CSSBlockTransform;
import org.daisy.pipeline.braille.common.CSSStyledDocumentTransform;
import org.daisy.pipeline.braille.common.XProcTransform;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.osgi.service.component.ComponentContext;

public interface LiblouisCSSStyledDocumentTransform extends XProcTransform, CSSStyledDocumentTransform {
	
	@Component(
		name = "org.daisy.pipeline.braille.liblouis.transform.LiblouisCSSStyledDocumentTransform.Provider",
		service = {
			XProcTransform.Provider.class,
			CSSStyledDocumentTransform.Provider.class
		}
	)
	public class Provider implements XProcTransform.Provider<LiblouisCSSStyledDocumentTransform>,
		                             CSSStyledDocumentTransform.Provider<LiblouisCSSStyledDocumentTransform> {
		
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
		public Iterable<LiblouisCSSStyledDocumentTransform> get(String query) {
			return Optional.<LiblouisCSSStyledDocumentTransform>fromNullable(transforms.get(query)).asSet();
		}
		
		private Cached<String,LiblouisCSSStyledDocumentTransform> transforms
		= new Cached<String,LiblouisCSSStyledDocumentTransform>() {
			public LiblouisCSSStyledDocumentTransform delegate(final String query) {
				final URI href = Provider.this.href;
				Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
				Optional<String> o;
				if ((o = q.remove("formatter")) != null)
					if (!o.get().equals("liblouis"))
						return null;
				String newQuery = serializeQuery(q);
				if (!cssBlockTransformProvider.get(newQuery).iterator().hasNext())
					return null;
				final Map<String,String> options = ImmutableMap.<String,String>of("query", newQuery);
				return new LiblouisCSSStyledDocumentTransform() {
					public Tuple3<URI,QName,Map<String,String>> asXProc() {
						return new Tuple3<URI,QName,Map<String,String>>(href, null, options); }};
			}
		};
		
		@Reference(
			name = "CSSBlockTransformProvider",
			unbind = "unbindCSSBlockTransformProvider",
			service = CSSBlockTransform.Provider.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		public void bindCSSBlockTransformProvider(CSSBlockTransform.Provider<?> provider) {
			if (provider instanceof XProcTransform.Provider)
				cssBlockTransformProviders.add(provider);
		}
		
		public void unbindCSSBlockTransformProvider(CSSBlockTransform.Provider<?> provider) {
			cssBlockTransformProviders.remove(provider);
			cssBlockTransformProvider.invalidateCache();
		}
	
		private List<org.daisy.pipeline.braille.common.Provider<String,? extends CSSBlockTransform>> cssBlockTransformProviders
		= new ArrayList<org.daisy.pipeline.braille.common.Provider<String,? extends CSSBlockTransform>>();
		
		private CachedProvider<String,CSSBlockTransform> cssBlockTransformProvider
		= CachedProvider.<String,CSSBlockTransform>newInstance(
			DispatchingProvider.<String,CSSBlockTransform>newInstance(cssBlockTransformProviders));
		
	}
}
