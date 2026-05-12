package config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import utils.LocalizedTextResolver;

import java.io.IOException;

@Component
public class RequestLocaleFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        try {
            String header = request.getHeader("Accept-Language");
            RequestLocaleContext.set(LocalizedTextResolver.normalizeLocale(header));
            filterChain.doFilter(request, response);
        } finally {
            RequestLocaleContext.clear();
        }
    }
}
