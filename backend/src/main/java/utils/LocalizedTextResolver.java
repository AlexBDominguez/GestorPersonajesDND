package utils;

public final class LocalizedTextResolver {

    private LocalizedTextResolver() {}

    public static String normalizeLocale(String raw) {
        if (raw == null || raw.isBlank()) {
            return "en";
        }

        String first = raw.split(",")[0].trim().toLowerCase();
        if (first.startsWith("gl")) {
            return "gl";
        }
        if (first.startsWith("es")) {
            return "es";
        }
        return "en";
    }

    public static String resolve(String locale, String baseEn, String es, String gl) {
        String lang = normalizeLocale(locale);
        if ("gl".equals(lang)) {
            return firstNonBlank(gl, es, baseEn);
        }
        if ("es".equals(lang)) {
            return firstNonBlank(es, baseEn, gl);
        }
        return firstNonBlank(baseEn, es, gl);
    }

    private static String firstNonBlank(String... options) {
        for (String option : options) {
            if (option != null && !option.isBlank()) {
                return option;
            }
        }
        return null;
    }
}
