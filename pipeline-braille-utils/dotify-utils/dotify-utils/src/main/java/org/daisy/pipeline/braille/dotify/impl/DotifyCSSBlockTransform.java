package org.daisy.pipeline.braille.dotify.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.net.URI;
import javax.xml.namespace.QName;

import com.google.common.collect.ImmutableMap;

import static org.daisy.pipeline.braille.common.util.Tuple3;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
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
		name = "org.daisy.pipeline.braille.dotify.impl.DotifyCSSBlockTransform.Provider",
		service = {
			XProcTransform.Provider.class,
			CSSBlockTransform.Provider.class
		}
	)
	public class Provider extends AbstractTransformProvider<DotifyCSSBlockTransform>
		                  implements XProcTransform.Provider<DotifyCSSBlockTransform>, CSSBlockTransform.Provider<DotifyCSSBlockTransform> {
		
		private URI href;
		
		@Activate
		private void activate(ComponentContext context, final Map<?,?> properties) {
			href = asURI(context.getBundleContext().getBundle().getEntry("xml/transform/dotify-block-translate.xpl"));
		}
		
		private final static Iterable<DotifyCSSBlockTransform> empty
		= Iterables.<DotifyCSSBlockTransform>empty();
		
		/**
		 * Recognized features:
		 *
		 * - translator: Will only match if the value is `dotify'.
		 * - locale: If present the value will be used instead of any xml:lang attributes.
		 *
		 * Other features are used for finding sub-transformers of type DotifyTranslator.
		 */
		protected Iterable<DotifyCSSBlockTransform> _get(Query query) {
			final MutableQuery q = mutableQuery(query);
			if (q.containsKey("translator"))
				if (!"dotify".equals(q.removeOnly("translator").getValue().get()))
					return empty;
			Iterable<DotifyTranslator> translators = logSelect(q, dotifyTranslatorProvider);
			return transform(
				translators,
				new Function<DotifyTranslator,DotifyCSSBlockTransform>() {
					public DotifyCSSBlockTransform _apply(DotifyTranslator translator) {
						return __apply(
							logCreate(new TransformImpl(q.toString(), translator))
						);
					}
				}
			);
		}
		
		private class TransformImpl extends AbstractTransform implements DotifyCSSBlockTransform {
			
			private final DotifyTranslator translator;
			private final Tuple3<URI,QName,Map<String,String>> xproc;
			
			private TransformImpl(String translatorQuery, DotifyTranslator translator) {
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
		}
		
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
		
		private List<TransformProvider<DotifyTranslator>> dotifyTranslatorProviders
		= new ArrayList<TransformProvider<DotifyTranslator>>();
		
		private TransformProvider.util.MemoizingProvider<DotifyTranslator> dotifyTranslatorProvider
		= memoize(dispatch(dotifyTranslatorProviders));
	
	}
}
