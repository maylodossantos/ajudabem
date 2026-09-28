package com.ajudabem.api.services.assisted_person;

import com.ajudabem.api.domains.assisted_person.Tag;
import com.ajudabem.api.dto.assited_person.AssistedPersonTagResponseDTO;
import com.ajudabem.api.dto.assited_person.TagRequestDTO;
import com.ajudabem.api.exceptions.TagAlreadyExistsException;
import com.ajudabem.api.exceptions.TagNotFoundException;
import com.ajudabem.api.repositories.TagRepository;
import com.ajudabem.api.services.user.CurrentUserService;
import com.ajudabem.api.services.user.Roles;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TagService {

    private static final String ADMIN_ONLY = "Only admins can manage needs";

    private final TagRepository tagRepository;
    private final CurrentUserService currentUserService;

    public List<AssistedPersonTagResponseDTO> getAll() {
        return tagRepository.findAllByOrderByNameAsc().stream()
                .map(TagService::toResponse)
                .toList();
    }

    @Transactional
    public AssistedPersonTagResponseDTO create(TagRequestDTO dto) {
        Roles.requireAdmin(currentUserService.get(), ADMIN_ONLY);
        String name = dto.name().trim();
        if (tagRepository.existsByNameIgnoreCase(name)) {
            throw new TagAlreadyExistsException("Tag already exists");
        }
        Tag tag = new Tag();
        tag.setName(name);
        return toResponse(tagRepository.save(tag));
    }

    @Transactional
    public AssistedPersonTagResponseDTO update(Long id, TagRequestDTO dto) {
        Roles.requireAdmin(currentUserService.get(), ADMIN_ONLY);
        Tag tag = findTag(id);
        String name = dto.name().trim();
        if (tagRepository.existsByNameIgnoreCaseAndIdNot(name, id)) {
            throw new TagAlreadyExistsException("Tag already exists");
        }
        tag.setName(name);
        return toResponse(tagRepository.save(tag));
    }

    @Transactional
    public void delete(Long id) {
        Roles.requireAdmin(currentUserService.get(), ADMIN_ONLY);
        Tag tag = findTag(id);
        tag.softDelete();
        tagRepository.save(tag);
    }

    private Tag findTag(Long id) {
        return tagRepository.findById(id)
                .orElseThrow(() -> new TagNotFoundException("Tag not found"));
    }

    private static AssistedPersonTagResponseDTO toResponse(Tag tag) {
        return new AssistedPersonTagResponseDTO(tag.getId(), tag.getName());
    }
}
