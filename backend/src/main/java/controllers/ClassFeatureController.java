package controllers;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import entities.ClassFeature;
import services.ClassFeatureService;

@RestController
@RequestMapping("/api/class-features")
public class ClassFeatureController {

    private final ClassFeatureService classFeatureService;

    public ClassFeatureController(ClassFeatureService classFeatureService) {
        this.classFeatureService = classFeatureService;
    }

    //Obtener todas las features de una clase
    @GetMapping("/class/{classId}")
    public List<ClassFeature> getFeaturesByClass(@PathVariable Long classId) {
        return classFeatureService.getFeaturesByClass(classId);
    }

    //Obtener features de una clase de un nivel específico
    @GetMapping("/class/{classId}/level/{level}")
    public List<ClassFeature> getFeaturesByClassAndLevel(
        @PathVariable Long classId,
        @PathVariable int level) {
        return classFeatureService.getFeaturesByClassAndLevel(classId, level);
    }

    //Obtener todas las features hasta un nivel
    @GetMapping("/class/{classId}/up-to-level/{level}")
    public List<ClassFeature> getFeaturesUpToLevel(
        @PathVariable Long classId,
        @PathVariable int level) {
        return classFeatureService.getFeaturesUpToLevel(classId, level);
    }   
}
