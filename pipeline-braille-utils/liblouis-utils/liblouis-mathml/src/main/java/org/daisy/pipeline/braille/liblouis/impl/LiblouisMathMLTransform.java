package org.daisy.pipeline.braille.liblouis.impl;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.net.URI;
import javax.xml.namespace.QName;

import com.google.common.base.Objects;
import com.google.common.base.Objects.ToStringHelper;
import com.google.common.base.Optional;
import com.google.common.collect.ImmutableMap;

import static org.daisy.pipeline.braille.css.Query.parseQuery;
import org.daisy.pipeline.braille.common.AbstractTransform;
import org.daisy.pipeline.braille.common.AbstractTransform.Provider.util.Iterables;
import static org.daisy.pipeline.braille.common.AbstractTransform.Provider.util.Iterables.of;
import static org.daisy.pipeline.braille.common.AbstractTransform.Provider.util.logCreate;
import org.daisy.pipeline.braille.common.MathMLTransform;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Tuple3;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.common.XProcTransform;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.ComponentContext;

public interface LiblouisMathMLTransform extends MathMLTransform, XProcTransform {
	
	public enum MathCode {
		NEMETH, UKMATHS, MARBURG, WOLUWE
	}
	
	@Component(
		name = "org.daisy.pipeline.braille.liblouis.impl.LiblouisMathMLTransform.Provider",
		service = {
			XProcTransform.Provider.class,
			MathMLTransform.Provider.class
		}
	)
	public class Provider extends AbstractTransform.Provider<LiblouisMathMLTransform>
		                  implements XProcTransform.Provider<LiblouisMathMLTransform>, MathMLTransform.Provider<LiblouisMathMLTransform> {
		
		private URI href;
		
		@Activate
		private void activate(ComponentContext context, final Map<?,?> properties) {
			href = asURI(context.getBundleContext().getBundle().getEntry("xml/translate-mathml.xpl"));
		}
		
		private final static Iterable<LiblouisMathMLTransform> empty
		= Iterables.<LiblouisMathMLTransform>empty();
		
		protected Iterable<LiblouisMathMLTransform> _get(final String query) {
			Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
			Optional<String> o;
			if ((o = q.get("locale")) != null) {
				MathCode code = mathCodeFromLocale(parseLocale(o.get()));
				if (code != null)
					return of(logCreate((LiblouisMathMLTransform)new TransformImpl(code))); }
			return empty;
		}
		
		private class TransformImpl extends AbstractTransform implements LiblouisMathMLTransform {
			
			private final MathCode code;
			private final Tuple3<URI,QName,Map<String,String>> xproc;
			
			private TransformImpl(MathCode code) {
				this.code = code;
				Map<String,String> options = ImmutableMap.of("math-code", code.name());
				xproc = new Tuple3<URI,QName,Map<String,String>>(href, null, options);
			}
			
			public Tuple3<URI,QName,Map<String,String>> asXProc() {
				return xproc;
			}
			
			@Override
			public ToStringHelper toStringHelper() {
				return Objects.toStringHelper("o.d.p.b.liblouis.impl.LiblouisMathMLTransform$Provider$TransformImpl")
					.add("mathCode", code);
			}
		}
		
		private static MathCode mathCodeFromLocale(Locale locale) {
			String language = locale.getLanguage().toLowerCase();
			String country = locale.getCountry().toUpperCase();
			if (language.equals("en")) {
				if (country.equals("GB"))
					return MathCode.UKMATHS;
				else
					return MathCode.NEMETH; }
			else if (language.equals("de"))
				return MathCode.MARBURG;
			else if (language.equals("nl"))
				return MathCode.WOLUWE;
			else
				return null;
		}
		
	}
}
