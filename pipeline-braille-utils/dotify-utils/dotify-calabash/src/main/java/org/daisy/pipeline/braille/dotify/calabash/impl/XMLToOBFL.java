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
import java.util.Locale;
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
import org.daisy.dotify.tasks.runner.TaskRunner;

import org.daisy.pipeline.braille.common.Query.Feature;
import static org.daisy.pipeline.braille.common.Query.util.query;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Optional;
import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;

public class XMLToOBFL extends DefaultStep {
	private static final QName _locale = new QName("locale");
	private static final QName _format = new QName("format");
	private static final QName _dotifyOptions = new QName("dotify-options");
	
	private static final QName _template = new QName("template");
    private static final QName _rows = new QName("rows");
    private static final QName _cols = new QName("cols");
    private static final QName _innerMargin = new QName("inner-margin");
    private static final QName _outerMargin = new QName("outer-margin");
    private static final QName _rowgap = new QName("rowgap");
    private static final QName _splitterMax = new QName("splitterMax");
    private static final QName _identifier = new QName("identifier");
	
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
			Map<String, Object> params = new HashMap<String, Object>();
			addOption(_template, params);
			addOption(_rows, params);
			addOption(_cols, params);
			addOption(_innerMargin, params);
			addOption(_outerMargin, params);
			addOption(_rowgap, params);
			addOption(_splitterMax, params);
			addOption(_identifier, params);
			
			RuntimeValue rv = getOption(_dotifyOptions);
			if (rv!=null) {
				for (Feature f : query(rv.getString())) {
					String key = f.getKey();
					Optional<String> val = f.getValue();
					//if there isn't a value, just repeat the key
					params.put(key, val.or(key));
				}
			}
			
			InputStream resultStream = convert(
					newTaskSystem(getOption(_locale, Locale.getDefault().toString()), getOption(_format, "obfl")), 
					inputStream, outputStream, params);
			
			// Write result
			result.write(runtime.getProcessor().newDocumentBuilder().build(new StreamSource(resultStream)));
			resultStream.close(); 
		} catch (Exception e) {
			logger.error("dotify:xml-to-obfl failed", e);
			throw new XProcException(step.getNode(), e);
		}
	}
	
	private void addOption(QName opt, Map<String, Object> params) {
		RuntimeValue o = getOption(opt);
		if (o!=null) {
			params.put(opt.getLocalName(), o.getString());
		}
	}
		
	private InputStream convert(TaskSystem system, InputStream is, OutputStream os, Map<String, Object> params) throws TaskSystemFactoryException, TaskSystemException, IOException {
		// Copy source to file
		File src = File.createTempFile("xml-to-obfl", ".tmp");
		src.deleteOnExit();
		FileIO.copy(is, new FileOutputStream(src));
		
		// These parameters are unfortunately required at the moment
		params.put("inputFormat", "xml");
		params.put("input", src.getAbsolutePath());
		List<InternalTask> tasks = system.compile(params);
		
		// Create a destination file
		File dest = File.createTempFile("xml-to-obfl", ".tmp");
		dest.deleteOnExit();
		
		// Run tasks
		TaskRunner runner = TaskRunner.withName("dotify:xml-to-obfl").build();
		runner.runTasks(src, dest, tasks);
		
		// Return stream
		return new FileInputStream(dest);
	}

	private TaskSystem newTaskSystem(String locale, String format) throws TaskSystemFactoryException {
		return taskSystemFactoryService.iterator().next().newTaskSystem(locale, format);
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
