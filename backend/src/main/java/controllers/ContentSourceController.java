package controllers;

import dto.ContentSourceDto;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import services.ContentSourceService;

import java.util.List;

@RestController
@RequestMapping("/api/content-sources")
public class ContentSourceController {

    private final ContentSourceService service;

    public ContentSourceController(ContentSourceService service) {
        this.service = service;
    }

    @GetMapping
    public List<ContentSourceDto> getAll() {
        return service.getAll();
    }
}
