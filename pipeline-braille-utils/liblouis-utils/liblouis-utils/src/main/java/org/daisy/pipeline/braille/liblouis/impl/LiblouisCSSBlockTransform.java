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
import static org.daisy.pipeline.braille.common.Provider.util.memoize;
import org.daisy.pipeline.braille.common.LazyValue.ImmutableLazyValue;
import org.daisy.pipeline.braille.common.Transform;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.dispatch;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.logCreate;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.logSelect;
import org.daisy.pipeline.braille.common.WithSideEffect;
import org.daisy.pipeline.braille.common.XProcTransform;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.osgi.service.component.ComponentContext;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public interface LiblouisCSSBlockTransform extends CSSBlockTransform, XProcTransform {
	
	@Component(
		name = "org.daisy.pipeline.braille.liblouis.impl.LiblouisCSSBlockTransform.Provider",
		service = {
			XProcTransform.Provider.class,
			CSSBlockTransform.Provider.class
		}
	)
	public class Provider implements XProcTransform.Provider<LiblouisCSSBlockTransform>, CSSBlockTransform.Provider<LiblouisCSSBlockTransform> {
		
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
		public Iterable<LiblouisCSSBlockTransform> get(String query) {
			return impl.get(query);
		}
		
		public Transform.Provider<LiblouisCSSBlockTransform> withContext(Logger context) {
			return impl.withContext(context);
		}
		
		private Transform.Provider<LiblouisCSSBlockTransform> impl = new ProviderImpl(null);
		
		private class ProviderImpl extends AbstractProvider<LiblouisCSSBlockTransform> {
			
			private ProviderImpl(Logger context) {
				super(context);
			}
			
			protected Transform.Provider.MemoizingProvider<LiblouisCSSBlockTransform> _withContext(Logger context) {
				return new ProviderImpl(context);
			}
			
			protected Iterable<WithSideEffect<LiblouisCSSBlockTransform,Logger>> __get(final String query) {
				return new ImmutableLazyValue<WithSideEffect<LiblouisCSSBlockTransform,Logger>>() {
					public WithSideEffect<LiblouisCSSBlockTransform,Logger> _apply() {
						return new WithSideEffect<LiblouisCSSBlockTransform,Logger>() {
							public LiblouisCSSBlockTransform _apply() {
								Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
								Optional<String> o;
								if ((o = q.remove("translator")) != null)
									if (!o.get().equals("liblouis"))
										throw new NoSuchElementException();
								String translatorQuery = serializeQuery(q);
								Iterable<WithSideEffect<LiblouisTranslator,Logger>> translators
									= logSelect(translatorQuery, liblouisTranslatorProvider.get(translatorQuery));
								LiblouisTranslator translator;
								try {
									translator = applyWithSideEffect( translators.iterator().next() ); }
								catch (NoSuchElementException e) {
									throw new NoSuchElementException(); }
								return applyWithSideEffect(
									logCreate(new TransformImpl(translatorQuery, translator))
								);
							}
						};
					}
				};
			}
		}
		
		private class TransformImpl implements LiblouisCSSBlockTransform {
			
			private final LiblouisTranslator translator;
			private final Tuple3<URI,QName,Map<String,String>> xproc;
			
			private TransformImpl(String translatorQuery, LiblouisTranslator translator) {
				Map<String,String> options = ImmutableMap.of("query", translatorQuery);
				xproc = new Tuple3<URI,QName,Map<String,String>>(href, null, options);
				this.translator = translator;
			}
			
			public Tuple3<URI,QName,Map<String,String>> asXProc() {
				return xproc;
			}
			
			@Override
			public String toString() {
				return toStringHelper(LiblouisCSSBlockTransform.class.getSimpleName())
					.add("translator", translator)
					.toString();
			}
		}
		
		@Reference(
			name = "LiblouisTranslatorProvider",
			unbind = "unbindLiblouisTranslatorProvider",
			service = LiblouisTranslator.Provider.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		protected void bindLiblouisTranslatorProvider(LiblouisTranslator.Provider provider) {
			liblouisTranslatorProviders.add(provider);
		}
	
		protected void unbindLiblouisTranslatorProvider(LiblouisTranslator.Provider provider) {
			liblouisTranslatorProviders.remove(provider);
			liblouisTranslatorProvider.invalidateCache();
		}
	
		private List<Transform.Provider<LiblouisTranslator>> liblouisTranslatorProviders
		= new ArrayList<Transform.Provider<LiblouisTranslator>>();
		private org.daisy.pipeline.braille.common.Provider.MemoizingProvider<String,LiblouisTranslator> liblouisTranslatorProvider
		= memoize(dispatch(liblouisTranslatorProviders));
		
		private static final Logger logger = LoggerFactory.getLogger(Provider.class);
		
	}
}
