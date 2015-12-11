package org.daisy.pipeline.braille.liblouis.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.net.URI;
import javax.xml.namespace.QName;

import com.google.common.base.Objects;
import com.google.common.base.Objects.ToStringHelper;
import com.google.common.collect.ImmutableMap;

import org.daisy.pipeline.braille.common.AbstractTransform;
import org.daisy.pipeline.braille.common.AbstractTransformProvider;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Function;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables.transform;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logCreate;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logSelect;
import org.daisy.pipeline.braille.common.CSSBlockTransform;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import org.daisy.pipeline.braille.common.TextTransform;
import org.daisy.pipeline.braille.common.TransformProvider;
import static org.daisy.pipeline.braille.common.TransformProvider.util.dispatch;
import static org.daisy.pipeline.braille.common.TransformProvider.util.memoize;
import static org.daisy.pipeline.braille.common.util.Tuple3;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
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
	public class Provider extends AbstractTransformProvider<LiblouisCSSBlockTransform>
		                  implements XProcTransform.Provider<LiblouisCSSBlockTransform>, CSSBlockTransform.Provider<LiblouisCSSBlockTransform> {
		
		private URI href;
		
		@Activate
		private void activate(ComponentContext context, final Map<?,?> properties) {
			href = asURI(context.getBundleContext().getBundle().getEntry("xml/transform/liblouis-block-translate.xpl"));
		}
		
		private final static Iterable<LiblouisCSSBlockTransform> empty
		= Iterables.<LiblouisCSSBlockTransform>empty();
		
		/**
		 * Recognized features:
		 *
		 * - translator: Will only match if the value is `liblouis'.
		 * - locale: If present the value will be used instead of any xml:lang attributes.
		 *
		 * Other features are used for finding sub-transformers of type LiblouisTranslator.
		 */
		protected Iterable<LiblouisCSSBlockTransform> _get(Query query) {
			final MutableQuery q = mutableQuery(query);
			if (q.containsKey("translator"))
				if (!"liblouis".equals(q.removeOnly("translator").getValue().get()))
					return empty;
			Iterable<LiblouisTranslator> translators = logSelect(q, liblouisTranslatorProvider);
			return transform(
				translators,
				new Function<LiblouisTranslator,LiblouisCSSBlockTransform>() {
					public LiblouisCSSBlockTransform _apply(LiblouisTranslator translator) {
						return __apply(
							logCreate(new TransformImpl(q.toString(), translator))
						);
					}
				}
			);
		}
		
		private class TransformImpl extends AbstractTransform implements LiblouisCSSBlockTransform {
			
			private final LiblouisTranslator translator;
			private final Tuple3<URI,QName,Map<String,String>> xproc;
			
			private TransformImpl(String translatorQuery, LiblouisTranslator translator) {
				Map<String,String> options = ImmutableMap.of("query", translatorQuery);
				xproc = new Tuple3<URI,QName,Map<String,String>>(href, null, options);
				this.translator = translator;
			}
			
			public TextTransform asTextTransform() {
				return translator;
			}
			
			public Tuple3<URI,QName,Map<String,String>> asXProc() {
				return xproc;
			}
			
			@Override
			public ToStringHelper toStringHelper() {
				return Objects.toStringHelper("o.d.p.b.liblouis.impl.LiblouisCSSBlockTransform$TransformImpl")
					.add("translator", translator);
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
	
		private List<TransformProvider<LiblouisTranslator>> liblouisTranslatorProviders
		= new ArrayList<TransformProvider<LiblouisTranslator>>();
		private TransformProvider.util.MemoizingProvider<LiblouisTranslator> liblouisTranslatorProvider
		= memoize(dispatch(liblouisTranslatorProviders));
		
		private static final Logger logger = LoggerFactory.getLogger(Provider.class);
		
	}
}
