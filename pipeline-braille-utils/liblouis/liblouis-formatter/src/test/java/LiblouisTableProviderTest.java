import org.daisy.braille.table.BrailleConverter;
import org.daisy.pipeline.braille.liblouis.pef.LiblouisTableProvider;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class LiblouisTableProviderTest {
	
	@Test
	public void testNabccEightDotBrailleConverter() {
		BrailleConverter converter = new LiblouisTableProvider().list().iterator().next().newBrailleConverter();
		assertEquals("⠋⠕⠕⠃⠁⠗", converter.toBraille("foobar"));
		assertEquals("foobar", converter.toText("⠋⠕⠕⠃⠁⠗"));
	}
}
