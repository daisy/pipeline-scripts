package org.daisy.pipeline.braille.liblouis.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.net.URI;

import javax.xml.namespace.QName;

import static com.google.common.base.Objects.toStringHelper;
import com.google.common.base.Optional;
import com.google.common.collect.ImmutableMap;

import static org.daisy.pipeline.braille.css.Query.parseQuery;
import static org.daisy.pipeline.braille.css.Query.serializeQuery;
import static org.daisy.pipeline.braille.common.util.Tuple3;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.common.CSSBlockTransform;
import org.daisy.pipeline.braille.common.CSSStyledDocumentTransform;
import org.daisy.pipeline.braille.common.LazyValue.ImmutableLazyValue;
import static org.daisy.pipeline.braille.common.Provider.util.memoize;
import org.daisy.pipeline.braille.common.Transform;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.dispatch;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.logCreate;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.logSelect;
import org.daisy.pipeline.braille.common.WithSideEffect;
import org.daisy.pipeline.braille.common.XProcTransform;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.osgi.service.component.ComponentContext;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public interface LiblouisCSSStyledDocumentTransform extends XProcTransform, CSSStyledDocumentTransform {
	
	@Component(
		name = "org.daisy.pipeline.braille.liblouis.impl.LiblouisCSSStyledDocumentTransform.Provider",
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
			return impl.get(query);
		}
		
		public Transform.Provider<LiblouisCSSStyledDocumentTransform> withContext(Logger context) {
			return impl.withContext(context);
		}
		
		private Transform.Provider<LiblouisCSSStyledDocumentTransform> impl = new ProviderImpl(null);
		
		private class ProviderImpl extends AbstractProvider<LiblouisCSSStyledDocumentTransform> {
			
			private ProviderImpl(Logger context) {
				super(context);
			}
			
			protected Transform.Provider.MemoizingProvider<LiblouisCSSStyledDocumentTransform> _withContext(Logger context) {
				return new ProviderImpl(context);
			}
			
			protected Iterable<WithSideEffect<LiblouisCSSStyledDocumentTransform,Logger>> __get(final String query) {
				return new ImmutableLazyValue<WithSideEffect<LiblouisCSSStyledDocumentTransform,Logger>>() {
					public WithSideEffect<LiblouisCSSStyledDocumentTransform,Logger> _apply() {
						return new WithSideEffect<LiblouisCSSStyledDocumentTransform,Logger>() {
							public LiblouisCSSStyledDocumentTransform _apply() {
								Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
								Optional<String> o;
								if ((o = q.remove("formatter")) != null)
									if (!o.get().equals("liblouis"))
										return null;
								String cssBlockTransformQuery = serializeQuery(q);
								Iterable<WithSideEffect<CSSBlockTransform,Logger>> cssBlockTransforms
									= logSelect(cssBlockTransformQuery, cssBlockTransformProvider.get(cssBlockTransformQuery));
								CSSBlockTransform cssBlockTransform;
								try {
									cssBlockTransform = applyWithSideEffect( cssBlockTransforms.iterator().next() ); }
								catch (NoSuchElementException e) {
									throw new NoSuchElementException(); }
								return applyWithSideEffect(
									logCreate(new TransformImpl(cssBlockTransformQuery, cssBlockTransform))
								);
							}
						};
					}
				};
			}
		}
		
		private class TransformImpl implements LiblouisCSSStyledDocumentTransform {
			
			private final CSSBlockTransform cssBlockTransform;
			private final Tuple3<URI,QName,Map<String,String>> xproc;
			
			private TransformImpl(String cssBlockTransformQuery, CSSBlockTransform cssBlockTransform) {
				Map<String,String> options = ImmutableMap.of("query", cssBlockTransformQuery);
				xproc = new Tuple3<URI,QName,Map<String,String>>(href, null, options);
				this.cssBlockTransform = cssBlockTransform;
			}
			
			public Tuple3<URI,QName,Map<String,String>> asXProc() {
				return xproc;
			}
			
			@Override
			public String toString() {
				return toStringHelper(LiblouisCSSStyledDocumentTransform.class.getSimpleName())
					.add("blockTransform", cssBlockTransform)
					.toString();
			}
		}
		
		@Reference(
			name = "CSSBlockTransformProvider",
			unbind = "unbindCSSBlockTransformProvider",
			service = CSSBlockTransform.Provider.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		@SuppressWarnings(
			"unchecked" // safe cast to Transform.Provider<CSSBlockTransform>
		)
		public void bindCSSBlockTransformProvider(CSSBlockTransform.Provider<?> provider) {
			if (provider instanceof XProcTransform.Provider)
				cssBlockTransformProviders.add((Transform.Provider<CSSBlockTransform>)provider);
		}
		
		public void unbindCSSBlockTransformProvider(CSSBlockTransform.Provider<?> provider) {
			cssBlockTransformProviders.remove(provider);
			cssBlockTransformProvider.invalidateCache();
		}
	
		private List<Transform.Provider<CSSBlockTransform>> cssBlockTransformProviders
		= new ArrayList<Transform.Provider<CSSBlockTransform>>();
		
		private org.daisy.pipeline.braille.common.Provider.MemoizingProvider<String,CSSBlockTransform> cssBlockTransformProvider
		= memoize(dispatch(cssBlockTransformProviders));
		
		private static final Logger logger = LoggerFactory.getLogger(Provider.class);
		
	}
}
