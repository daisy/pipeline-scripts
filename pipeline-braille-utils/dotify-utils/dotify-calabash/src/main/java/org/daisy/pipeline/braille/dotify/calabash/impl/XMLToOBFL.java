package org.daisy.pipeline.braille.dotify.calabash.impl;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.transform.stream.StreamSource;

import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.daisy.dotify.api.tasks.InternalTask;
import org.daisy.dotify.api.tasks.ReadOnlyTask;
import org.daisy.dotify.api.tasks.ReadWriteTask;
import org.daisy.dotify.api.tasks.TaskSystem;
import org.daisy.dotify.api.tasks.TaskSystemException;
import org.daisy.dotify.api.tasks.TaskSystemFactoryException;
import org.daisy.dotify.api.tasks.TaskSystemFactoryMakerService;
import org.daisy.dotify.common.io.FileIO;
import org.daisy.dotify.common.io.TempFileHandler;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;

public class XMLToOBFL extends DefaultStep {
	private static final QName _locale = new QName("locale");
	
	private ReadablePipe source = null;
	private WritablePipe result = null;
	
	private final Iterable<TaskSystemFactoryMakerService> taskSystemFactoryService;
	
	public XMLToOBFL(XProcRuntime runtime,
	                     XAtomicStep step,
	                     Iterable<TaskSystemFactoryMakerService> taskSystemFactoryService) {
		super(runtime, step);
		this.taskSystemFactoryService = taskSystemFactoryService;
	}
	
	@Override
	public void setInput(String port, ReadablePipe pipe) {
		source = pipe;
	}
	
	@Override
	public void setOutput(String port, WritablePipe pipe) {
		result = pipe;
	}
	
	@Override
	public void reset() {
		source.resetReader();
		result.resetWriter();
	}
	
	@Override
	public void run() throws SaxonApiException {
		super.run();
		try {
			
			// Read OBFL
			ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
			Serializer serializer = new Serializer(outputStream);
			serializer.serializeNode(source.read());
			serializer.close();
			InputStream inputStream = new ByteArrayInputStream(outputStream.toByteArray());
			outputStream.close();
			
			// Convert
			// TODO: Get options from XPROC / query / whatever
			Map<String, Object> params = new HashMap<String, Object>();
			InputStream resultStream = convert(inputStream, outputStream, params);
			
			// Write result
			result.write(runtime.getProcessor().newDocumentBuilder().build(new StreamSource(resultStream)));
			resultStream.close(); 
		} catch (Exception e) {
			logger.error("dotify:xml-to-obfl failed", e);
			throw new XProcException(step.getNode(), e);
		}
	}
		
	private InputStream convert(InputStream is, OutputStream os, Map<String, Object> params) throws TaskSystemFactoryException, TaskSystemException, IOException {
		// Copy source to file
		File src = File.createTempFile("xml2obfl", ".tmp");
		src.deleteOnExit();
		FileIO.copy(is, new FileOutputStream(src));

		// Get tasks
		TaskSystem system = newTaskSystem(getOption(_locale).getString());
		// These parameters are unfortunately required at the moment
		params.put("inputFormat", "xml");
		params.put("input", src.getAbsolutePath());
		List<InternalTask> tasks = system.compile(params);
		
		// Create a destination file
		File dest = File.createTempFile("xml2obfl", ".tmp");
		dest.deleteOnExit();
		
		// Run tasks
		TempFileHandler fj = new TempFileHandler(src, dest);
		for (InternalTask task : tasks) {
			if (task instanceof ReadWriteTask) {
				logger.info("Running (r/w) " + task.getName());
				((ReadWriteTask)task).execute(fj.getInput(), fj.getOutput());
				fj.reset();
			} else if (task instanceof ReadOnlyTask) {
				logger.info("Running (r) " + task.getName());
				((ReadOnlyTask)task).execute(fj.getInput());
			} else {
				logger.warn("Unknown task type, skipping.");
			}
		}
		fj.close();
		// Return stream
		return new FileInputStream(dest);
	}

	private TaskSystem newTaskSystem(String locale) throws TaskSystemFactoryException {
		return taskSystemFactoryService.iterator().next().newTaskSystem(locale, "obfl");
	}
	
	@Component(
		name = "dotify:xml-to-obfl",
		service = { XProcStepProvider.class },
		property = { "type:String={http://code.google.com/p/dotify/}xml-to-obfl" }
	)
	public static class Provider implements XProcStepProvider {
		
		@Override
		public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
			return new XMLToOBFL(runtime, step, taskSystemFactoryService);
		}
			
		private List<TaskSystemFactoryMakerService> taskSystemFactoryService
			= new ArrayList<TaskSystemFactoryMakerService>();
		
		@Reference(
			name = "TaskSystemFactoryMakerService",
			unbind = "unbindTaskSystemFactoryMakerService",
			service = TaskSystemFactoryMakerService.class,
			cardinality = ReferenceCardinality.MANDATORY,
			policy = ReferencePolicy.STATIC
		)
		protected void bindTaskSystemFactoryMakerService(TaskSystemFactoryMakerService service) {
			taskSystemFactoryService.add(service);
		}
	
		protected void unbindTaskSystemFactoryMakerServicee(TaskSystemFactoryMakerService service) {
			taskSystemFactoryService.remove(service);
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(XMLToOBFL.class);
	
}
