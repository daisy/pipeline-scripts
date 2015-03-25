import com.google.common.base.Optional;
import com.google.common.collect.ImmutableMap;

import static org.daisy.braille.css.Query.parseQuery;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class QueryTest {
	
	@Test
	public void testParseQuery() {
		assertEquals(ImmutableMap.<String,Optional<String>>of("locale", Optional.<String>of("en-US"),
		                                                      "grade", Optional.<String>of("2"),
		                                                      "foo", Optional.<String>absent()),
		             parseQuery(" (locale:en-US ) ( grade: 2)(foo) (locale:fr)"));
	}
}
