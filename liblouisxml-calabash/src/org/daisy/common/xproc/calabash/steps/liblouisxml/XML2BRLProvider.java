package org.daisy.common.xproc.calabash.steps.liblouisxml;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.URL;
import java.util.Enumeration;

import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.osgi.framework.Bundle;
import org.osgi.service.component.ComponentContext;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.runtime.XAtomicStep;

public class XML2BRLProvider implements XProcStepProvider {

	private File configPath = null;

	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new XML2BRL(runtime, step, configPath);
	}

	public void start(ComponentContext context) {
		configPath = context.getBundleContext().getDataFile("lbx_files");
		if (!configPath.exists()) {
			configPath.mkdir();
			Bundle bundle = context.getBundleContext().getBundle();
			if (bundle.getEntry("/lbx_files") != null) {
				Enumeration<String> configFilePaths = bundle.getEntryPaths("/lbx_files");
				if (configFilePaths != null) {
					System.out.println("Unpacking liblouisxml config files...");
					while (configFilePaths.hasMoreElements()) {
						URL tableURL = bundle.getEntry(configFilePaths.nextElement());
						String url = tableURL.toExternalForm();
						String fileName = url.substring(url.lastIndexOf('/')+1, url.length());
						File file = new File(configPath.getAbsolutePath() + File.separator + fileName);
						try {
							unpack(tableURL, file);
							System.out.println(fileName);
						} catch (Exception e) {
							System.out.println("Exception occured during unpacking of file '" + fileName + "'");
							e.printStackTrace();
						}
					}
				}
			}
		}
	}

	private static void unpack(URL url, File file) throws Exception {
		file.createNewFile();
		FileOutputStream writer = new FileOutputStream(file);
		url.openConnection();
		InputStream reader = url.openStream();
		byte[] buffer = new byte[153600];
		int bytesRead = 0;
		while ((bytesRead = reader.read(buffer)) > 0) {
			writer.write(buffer, 0, bytesRead);
			buffer = new byte[153600];
		}
		writer.close();
		reader.close();
	}
}
