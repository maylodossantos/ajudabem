package com.ajudabem.api.controllers;

import com.ajudabem.api.domains.assisted_person.Tag;
import com.ajudabem.api.services.assisted_person.TagService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/tag")
public class TagsController {

    private final TagService tagService;

    @GetMapping
    public ResponseEntity<List<Tag>> getAllNews() {
        return ResponseEntity.ok(tagService.getAll());
    }

}
