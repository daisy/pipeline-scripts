package org.daisy.pipeline.braille.css;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableMap;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class QueryTest {
	
	@Test
	public void testParseQuery() {
		assertEquals(ImmutableMap.<String,Optional<String>>of("locale", Optional.<String>of("en-US"),
		                                                      "grade", Optional.<String>of("2"),
		                                                      "foo", Optional.<String>absent()),
		             Query.parseQuery(" (locale:en-US ) ( grade: 2)(foo) (locale:fr)"));
	}
	
	@Test
	public void testSerializeQuery() {
		assertEquals("(locale:en-US)(grade:2)(foo)",
		             Query.serializeQuery(ImmutableMap.<String,Optional<String>>of("locale", Optional.<String>of("en-US"),
		                                                                           "grade", Optional.<String>of("2"),
		                                                                           "foo", Optional.<String>absent())));
	}
}
