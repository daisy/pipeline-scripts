package org.daisy.pipeline.braille.liblouis.math;

import java.util.Locale;
import java.util.Map;
import java.net.URI;
import javax.xml.namespace.QName;

import static com.google.common.base.Objects.toStringHelper;
import com.google.common.base.Optional;
import com.google.common.collect.ImmutableMap;

import static org.daisy.pipeline.braille.css.Query.parseQuery;
import org.daisy.pipeline.braille.common.Memoizing;
import org.daisy.pipeline.braille.common.MathMLTransform;
import org.daisy.pipeline.braille.common.Transform;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.logCreate;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Tuple3;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.common.XProcTransform;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.ComponentContext;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public interface LiblouisMathMLTransform extends MathMLTransform, XProcTransform {
	
	public enum MathCode {
		NEMETH, UKMATHS, MARBURG, WOLUWE
	}
	
	@Component(
		name = "org.daisy.pipeline.braille.liblouis.math.LiblouisMathMLTransform.Provider",
		service = {
			XProcTransform.Provider.class,
			MathMLTransform.Provider.class
		}
	)
	public class Provider implements XProcTransform.Provider<LiblouisMathMLTransform>, MathMLTransform.Provider<LiblouisMathMLTransform> {
		
		private URI href;
		
		@Activate
		private void activate(ComponentContext context, final Map<?,?> properties) {
			href = asURI(context.getBundleContext().getBundle().getEntry("xml/translate-mathml.xpl"));
		}
		
		public LiblouisMathMLTransform get(MathCode code) {
			return translators.apply(code);
		}
		
		private Memoizing<MathCode,LiblouisMathMLTransform> translators
		= new Memoizing<MathCode,LiblouisMathMLTransform>() {
			public LiblouisMathMLTransform _apply(final MathCode code) {
				final URI href = Provider.this.href;
				return logCreate(
					new LiblouisMathMLTransform() {
						private final Map<String,String> options = ImmutableMap.of("math-code", code.name());
						public Tuple3<URI,QName,Map<String,String>> asXProc() {
							return new Tuple3<URI,QName,Map<String,String>>(href, null, options);
						}
						@Override
						public String toString() {
							return toStringHelper(LiblouisMathMLTransform.class.getSimpleName()).add("mathCode", code).toString();
						}
					}).apply(logger);
			}
		};
		
		public Iterable<LiblouisMathMLTransform> get(String query) {
			Map<String,Optional<String>> q = parseQuery(query);
			if (q.containsKey("locale")) {
				MathCode code = mathCodeFromLocale(parseLocale(q.get("locale").get()));
				if (code != null)
					return Optional.of(get(code)).asSet(); }
			return Optional.<LiblouisMathMLTransform>absent().asSet();
		}
		
		public Transform.Provider<LiblouisMathMLTransform> withContext(Logger context) {
			return this;
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
		
		private static final Logger logger = LoggerFactory.getLogger(Provider.class);
		
	}
}
