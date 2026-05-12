package config;

public final class RequestLocaleContext {

    private static final ThreadLocal<String> CURRENT = new ThreadLocal<>();

    private RequestLocaleContext() {}

    public static void set(String locale) {
        CURRENT.set(locale);
    }

    public static String get() {
        return CURRENT.get();
    }

    public static void clear() {
        CURRENT.remove();
    }
}
