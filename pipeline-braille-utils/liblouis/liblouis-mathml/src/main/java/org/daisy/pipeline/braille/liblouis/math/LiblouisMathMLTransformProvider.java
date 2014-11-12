package org.daisy.pipeline.braille.liblouis.math;

import java.util.Locale;
import java.util.Map;
import java.net.URI;
import javax.xml.namespace.QName;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableMap;

import static org.daisy.braille.css.Query.parseQuery;
import org.daisy.pipeline.braille.common.Cached;
import org.daisy.pipeline.braille.common.MathMLTransform;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Tuple3;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.common.XProcTransform;
import org.daisy.pipeline.braille.liblouis.math.LiblouisMathMLTransform.MathCode;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.ComponentContext;

@Component(
	name = "org.daisy.pipeline.braille.liblouis.math.LiblouisMathMLTransformProvider",
	service = { XProcTransform.Provider.class }
)
public class LiblouisMathMLTransformProvider implements XProcTransform.Provider<LiblouisMathMLTransform> {
	
	private URI href;
	
	@Activate
	private void activate(ComponentContext context, final Map<?,?> properties) {
		href = asURI(context.getBundleContext().getBundle().getEntry("xml/translate-mathml.xpl"));
	}
	
	public LiblouisMathMLTransform get(MathCode code) {
		return translators.get(code);
	}
	
	private Cached<MathCode,LiblouisMathMLTransform> translators
		= new Cached<MathCode,LiblouisMathMLTransform>() {
			public LiblouisMathMLTransform delegate(final MathCode code) {
				final URI href = LiblouisMathMLTransformProvider.this.href;
				return new LiblouisMathMLTransform() {
					private final Map<String,String> options = ImmutableMap.<String,String>of("math-code", code.name());
					public Tuple3<URI,QName,Map<String,String>> asXProc() {
						return new Tuple3<URI,QName,Map<String,String>>(href, null, options); }}; }};
	
	public Iterable<LiblouisMathMLTransform> get(String query) {
		Map<String,Optional<String>> q = parseQuery(query);
		if (q.containsKey("locale")) {
			MathCode code = mathCodeFromLocale(parseLocale(q.get("locale").get()));
			if (code != null)
				return Optional.<LiblouisMathMLTransform>of(get(code)).asSet(); }
		return Optional.<LiblouisMathMLTransform>absent().asSet();
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
