package com.aasha.web.controller;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class RelocationCsvTest {
 @Test void parsesQuotedCommaAndNewline(){var rows=RelocationController.parseCsv("id,name\r\n1,\"Village, East\"\r\n2,\"Two\nlines\"\n");assertEquals(3,rows.size());assertEquals("Village, East",rows.get(1).get(1));assertEquals("Two\nlines",rows.get(2).get(1));}
 @Test void rejectsUnclosedQuotes(){assertThrows(IllegalArgumentException.class,()->RelocationController.parseCsv("id,name\n1,\"bad"));}
}
