package org.daisy.pipeline.braille.maven.plugin;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.util.List;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;

import org.daisy.maven.xproc.api.XProcEngine;
import org.daisy.maven.xproc.api.XProcExecutionException;
import org.daisy.maven.xproc.calabash.Calabash;

@Mojo(
	name = "catalog-to-ds",
	defaultPhase = LifecyclePhase.GENERATE_RESOURCES
)
public class ProcessCatalogMojo extends AbstractMojo {
	
	@Parameter(
		readonly = true,
		defaultValue = "${project.basedir}/src/main/resources/META-INF/catalog.xml"
	)
	private File catalogFile;
	
	@Parameter(
		readonly = true,
		defaultValue = "${project.build.directory}/generated-resources/"
	)
	private File outputDirectory;
	
	@Parameter(
		readonly = true,
		defaultValue = "${project.version}"
	)
	private String projectVersion;
	
	public void execute() throws MojoFailureException {
		try {
			XProcEngine engine = new Calabash();
			engine.run(asURI(this.getClass().getResource("/org/daisy/pipeline/braille/build/catalog-to-ds.xpl")).toASCIIString(),
			           ImmutableMap.of("source", (List<String>)ImmutableList.of(asURI(catalogFile).toASCIIString())),
			           null,
			           ImmutableMap.of("outputDir", asURI(outputDirectory).toASCIIString(),
			                           "version", projectVersion),
			           null);
		} catch (Throwable e) {
			e.printStackTrace();
			throw new MojoFailureException(e.getMessage(), e);
		}
	}
	
	// TODO: use org.daisy.pipeline.braille.common.util.URIs.asURI
	public static URI asURI(Object o) {
		if (o == null)
			return null;
		try {
			if (o instanceof String)
				return new URI((String)o);
			if (o instanceof File)
				return ((File)o).toURI();
			if (o instanceof URL) {
				URL url = (URL)o;
				if (url.getProtocol().equals("jar"))
					return new URI("jar:" + new URI(null, url.getAuthority(), url.getPath(), url.getQuery(), url.getRef()).toASCIIString());
				String authority = (url.getPort() != -1) ?
					url.getHost() + ":" + url.getPort() :
					url.getHost();
				return new URI(url.getProtocol(), authority, url.getPath(), url.getQuery(), url.getRef()); }
			if (o instanceof URI)
				return (URI)o; }
		catch (Exception e) {}
		throw new RuntimeException("Object can not be converted to URI: " + o);
	}
}
