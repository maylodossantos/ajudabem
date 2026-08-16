package com.ajudabem.api.services.assisted_person;

import com.ajudabem.api.domains.assisted_person.Tag;
import com.ajudabem.api.repositories.TagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TagService {

    private final TagRepository tagRepository;

    public List<Tag> getAll() {
        return tagRepository.findAll();
    }
}
