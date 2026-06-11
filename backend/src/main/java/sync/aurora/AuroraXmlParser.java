package sync.aurora;

import org.springframework.stereotype.Service;
import org.w3c.dom.*;
import org.xml.sax.InputSource;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.StringReader;
import java.util.*;

/**
 * Parses Aurora Legacy Elements XML files into AuroraElement POJOs.
 * Only processes top-level <element> nodes (direct children of <elements> root).
 */
@Service
public class AuroraXmlParser {

    private final DocumentBuilderFactory factory;

    public AuroraXmlParser() {
        factory = DocumentBuilderFactory.newInstance();
        try {
            factory.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
            factory.setFeature("http://xml.org/sax/features/external-general-entities", false);
            factory.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
            factory.setExpandEntityReferences(false);
        } catch (Exception e) {
            System.err.println("[Aurora] Warning: could not configure XML security features: " + e.getMessage());
        }
    }

    public List<AuroraElement> parse(String xmlContent) {
        List<AuroraElement> results = new ArrayList<>();
        if (xmlContent == null || xmlContent.isBlank()) return results;

        // Strip UTF-8 BOM if present (U+FEFF = char 65279)
        if (!xmlContent.isEmpty() && xmlContent.charAt(0) == 65279) {
            xmlContent = xmlContent.substring(1);
        }

        try {
            DocumentBuilder builder = factory.newDocumentBuilder();
            builder.setErrorHandler(null); // suppress SAX warnings
            Document doc = builder.parse(new InputSource(new StringReader(xmlContent)));
            doc.getDocumentElement().normalize();

            // Only process direct children to avoid picking up nested <element> nodes
            NodeList children = doc.getDocumentElement().getChildNodes();
            for (int i = 0; i < children.getLength(); i++) {
                Node node = children.item(i);
                if (node.getNodeType() == Node.ELEMENT_NODE && "element".equals(node.getNodeName())) {
                    AuroraElement ae = parseElement((Element) node);
                    if (ae != null) results.add(ae);
                }
            }
        } catch (Exception e) {
            System.err.println("[Aurora] XML parse error: " + e.getMessage());
        }
        return results;
    }

    private AuroraElement parseElement(Element xml) {
        String id       = xml.getAttribute("id");
        String name     = xml.getAttribute("name");
        String type     = xml.getAttribute("type");
        String source   = xml.getAttribute("source");
        String supports = xml.getAttribute("supports"); // attribute form (used by Archetype, Sub Race, etc.)

        if (id.isBlank() || name.isBlank() || type.isBlank()) return null;

        AuroraElement el = new AuroraElement();
        el.setId(id);
        el.setName(name.trim());
        el.setType(type.trim());
        el.setSource(source.trim());
        if (!supports.isBlank()) el.setSupports(supports.trim()); // child <supports> may override below

        for (Node child = xml.getFirstChild(); child != null; child = child.getNextSibling()) {
            if (child.getNodeType() != Node.ELEMENT_NODE) continue;
            Element c = (Element) child;
            switch (c.getNodeName()) {
                case "description" -> el.setDescription(extractText(c).trim());
                case "sheet"       -> parseSheet(c, el);
                // Child <supports> only used when no supports attribute on the element tag.
                // For Archetype: attribute="Barbarian" (parent class), child="Primal Path" (group) — attribute wins.
                // For Spell: attribute empty, child="Wizard, Druid" (spell lists) — child sets it.
                case "supports"    -> { if (el.getSupports() == null || el.getSupports().isBlank()) el.setSupports(c.getTextContent().trim()); }
                case "requirements"-> el.setRequirements(c.getTextContent().trim());
                case "rules"       -> parseRules(c, el);
                case "setters"     -> parseSetters(c, el);
            }
        }
        return el;
    }

    private void parseSheet(Element sheetEl, AuroraElement el) {
        for (Node child = sheetEl.getFirstChild(); child != null; child = child.getNextSibling()) {
            if (child.getNodeType() == Node.ELEMENT_NODE && "description".equals(child.getNodeName())) {
                el.setSheetDescription(extractText((Element) child).trim());
                break;
            }
        }
    }

    private void parseRules(Element rulesEl, AuroraElement el) {
        for (Node child = rulesEl.getFirstChild(); child != null; child = child.getNextSibling()) {
            if (child.getNodeType() != Node.ELEMENT_NODE) continue;
            AuroraRule rule = parseRule((Element) child);
            if (rule != null) el.getRules().add(rule);
        }
    }

    private AuroraRule parseRule(Element xml) {
        AuroraRule rule = new AuroraRule();
        switch (xml.getNodeName()) {
            case "grant" -> {
                rule.setRuleType(AuroraRule.RuleType.GRANT);
                rule.setType(xml.getAttribute("type"));
                rule.setId(xml.getAttribute("id"));
                rule.setName(xml.getAttribute("name"));
                parseLevel(xml, rule);
                rule.setRequirements(xml.getAttribute("requirements"));
            }
            case "select" -> {
                rule.setRuleType(AuroraRule.RuleType.SELECT);
                rule.setType(xml.getAttribute("type"));
                rule.setName(xml.getAttribute("name"));
                rule.setSupports(xml.getAttribute("supports"));
                parseLevel(xml, rule);
                rule.setRequirements(xml.getAttribute("requirements"));
            }
            case "stat" -> {
                rule.setRuleType(AuroraRule.RuleType.STAT);
                rule.setName(xml.getAttribute("name"));
                rule.setValue(xml.getAttribute("value"));
                rule.setBonus(xml.getAttribute("bonus"));
                rule.setRequirements(xml.getAttribute("requirements"));
            }
            case "bonus" -> {
                rule.setRuleType(AuroraRule.RuleType.BONUS);
                rule.setType(xml.getAttribute("type"));
                rule.setValue(xml.getAttribute("value"));
                rule.setRequirements(xml.getAttribute("requirements"));
            }
            default -> { return null; }
        }
        return rule;
    }

    private void parseLevel(Element xml, AuroraRule rule) {
        String lvl = xml.getAttribute("level");
        if (!lvl.isBlank()) {
            try { rule.setLevel(Integer.parseInt(lvl.trim())); } catch (NumberFormatException ignored) {}
        }
    }

    private void parseSetters(Element settersEl, AuroraElement el) {
        NodeList sets = settersEl.getElementsByTagName("set");
        for (int i = 0; i < sets.getLength(); i++) {
            Element setEl = (Element) sets.item(i);
            String key = setEl.getAttribute("name");
            if (!key.isBlank()) {
                el.getSetters().put(key.trim(), setEl.getTextContent().trim());
            }
        }
    }

    /** Recursively extracts text, adding newlines after block-level tags. */
    private String extractText(Node node) {
        StringBuilder sb = new StringBuilder();
        extractTextRec(node, sb);
        return sb.toString();
    }

    private void extractTextRec(Node node, StringBuilder sb) {
        for (Node child = node.getFirstChild(); child != null; child = child.getNextSibling()) {
            if (child.getNodeType() == Node.TEXT_NODE) {
                String t = child.getTextContent();
                if (!t.isBlank()) sb.append(t.strip()).append(' ');
            } else if (child.getNodeType() == Node.ELEMENT_NODE) {
                String tag = child.getNodeName().toLowerCase();
                extractTextRec(child, sb);
                if (tag.equals("p") || tag.startsWith("h") || tag.equals("div") || tag.equals("li")) {
                    // Trim trailing space and add newline between paragraphs
                    if (!sb.isEmpty() && sb.charAt(sb.length() - 1) == ' ') {
                        sb.setCharAt(sb.length() - 1, '\n');
                    } else {
                        sb.append('\n');
                    }
                }
            }
        }
    }
}
