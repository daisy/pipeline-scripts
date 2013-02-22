package org.daisy.pipeline.braille;

import java.io.InputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;

import com.google.common.collect.ImmutableMap;

import org.osgi.service.component.ComponentContext;

import static org.daisy.pipeline.braille.Utilities.Files.resolveURL;
import static org.daisy.pipeline.braille.Utilities.Locales.parseLocale;

public abstract class BundledTablePath extends BundledResourcePath implements ResourceLookup<Locale> {
	
	private static final String MANIFEST = "manifest";
	
	private Map<Locale,URL> lookupMap = null;
	
	@Override
	public void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		super.activate(context, properties);
		if (properties.get(MANIFEST) != null) {
			String manifestPath = properties.get(MANIFEST).toString();
			URL manifestURL = context.getBundleContext().getBundle().getEntry(manifestPath);
			if (manifestURL == null)
				throw new IllegalArgumentException("Manifest at location " + manifestPath + " could not be found");
			lookupMap = readManifest(manifestURL); }
	}
	
	public URL lookup(Locale locale) {
		if (lookupMap == null)
			return null;
		return lookupMap.get(locale);
	}
	
	private Map<Locale,URL> readManifest(URL url) {
		Map<Locale,URL> map = new HashMap<Locale,URL>();
		try {
			url.openConnection();
			InputStream reader = url.openStream();
			Properties properties = new Properties();
			properties.loadFromXML(reader);
			for (String key : properties.stringPropertyNames()) {
				Locale locale = parseLocale(key);
				if (!map.containsKey(locale)) {
					map.put(locale, resolveURL(identifier, properties.getProperty(key))); }}
			reader.close();
			return new ImmutableMap.Builder<Locale,URL>().putAll(map).build(); }
		catch (Exception e) {
			throw new RuntimeException("Could not read manifest for table path " + getIdentifier(), e); }
	}
	
	@Override
	public boolean equals(Object object) {
		if (this == object)
			return true;
		if (object == null)
			return false;
		if (getClass() != object.getClass())
			return false;
		return super.equals((BundledResourcePath)object);
	}
}
