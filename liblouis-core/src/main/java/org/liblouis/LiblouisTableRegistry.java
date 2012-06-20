package org.liblouis;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class LiblouisTableRegistry {

	private static final Map<String,LiblouisTableSet> registeredTableSets = new HashMap<String,LiblouisTableSet>();

	public void addTableSet(LiblouisTableSet tableSet) {
		System.out.println("Adding table set to registry: " + tableSet.getIdentifier());
		registeredTableSets.put(tableSet.getIdentifier(), tableSet);
	}

	public void removeTableSet(LiblouisTableSet tableSet) {
		System.out.println("Removing table set from registry: " + tableSet.getIdentifier());
		registeredTableSets.remove(tableSet.getIdentifier());
	}

	public static Set<String> getRegisteredTableSets() {
		return registeredTableSets.keySet();
	}

	public static String getLouisTablePath(String[] ids) {
		List<String> paths = new ArrayList<String>();
		for (String id : ids) {
			if (registeredTableSets.containsKey(id)) {
				paths.add(registeredTableSets.get(id).getPath().getAbsolutePath());
			}
		}
		return StringUtils.join(paths, ",");
	}

	public static String getLouisTablePath(String id) {
		return getLouisTablePath(new String[]{id});
	}

	public static String getLouisTablePath() {
		List<String> paths = new ArrayList<String>();
		for (LiblouisTableSet tableSet : registeredTableSets.values()) {
			paths.add(tableSet.getPath().getAbsolutePath());
		}
		return StringUtils.join(paths, ",");
	}
}
