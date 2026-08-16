package com.ajudabem.api.services.assisted_person;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.assisted_person.AssistedPersonTag;
import com.ajudabem.api.domains.assisted_person.RiskLevel;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.dto.assited_person.AssistedPersonRequestDTO;
import com.ajudabem.api.dto.assited_person.AssistedPersonResponseDTO;
import com.ajudabem.api.mappers.AssistedPersonMapper;
import com.ajudabem.api.repositories.AssistedPersonRepository;
import com.ajudabem.api.repositories.AssistedPersonTagRepository;
import com.ajudabem.api.repositories.TagRepository;
import com.ajudabem.api.services.user.CurrentUserService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AssistedPersonService {

    private final AssistedPersonRepository assistedPersonRepository;
    private final AssistedPersonTagRepository assistedPersonTagRepository;
    private final CurrentUserService currentUserService;
    private final TagRepository tagRepository;
    private final AssistedPersonMapper mapper;

    @Transactional
    public AssistedPersonResponseDTO createAssistedPerson(AssistedPersonRequestDTO dto) {

        User user = currentUserService.get();

        //-> person

        AssistedPerson assistedPerson = mapper.toEntity(dto);

        assistedPerson.setAuthor(user);
        assistedPerson.setRiskLevel(RiskLevel.MEDIUM);

        assistedPersonRepository.save(assistedPerson);

        //-> tags

        List<AssistedPersonTag> tags = createTags(assistedPerson, dto.tagIds());

        assistedPersonTagRepository.saveAll(tags);

        return mapper.toResponse(assistedPerson, tags);
    }

    @Transactional
    public AssistedPersonResponseDTO updateAssistedPerson(AssistedPersonRequestDTO dto, Long id) {

        AssistedPerson assistedPerson = assistedPersonRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Assisted person is not exists"));

        //-> person

        mapper.updateEntity(dto, assistedPerson);

        //-> tags

        assistedPersonTagRepository.deleteByAssistedPerson(assistedPerson);
        List<AssistedPersonTag> tags = createTags(assistedPerson, dto.tagIds());
        assistedPersonTagRepository.saveAll(tags);

        assistedPersonRepository.save(assistedPerson);

        return mapper.toResponse(assistedPerson, tags);
    }

    public List<AssistedPersonResponseDTO> getAll() {
        List<AssistedPerson> assistedPerson= assistedPersonRepository.findAll();
        List<AssistedPersonTag> tags = assistedPersonTagRepository.findAll();

        Map<Long, List<AssistedPersonTag>> tagsByPerson = tags.stream()
                .collect(Collectors.groupingBy(
                        tag -> tag.getAssistedPerson().getId()
                ));

        return assistedPerson.stream()
                .map(person -> {
                    List<AssistedPersonTag> personTags =
                            tagsByPerson.getOrDefault(person.getId(), List.of());

                    return mapper.toResponse(person, personTags);
                })
                .toList();
    }

    public AssistedPersonResponseDTO getAssistedPerson(Long id) {
        AssistedPerson assistedPerson = assistedPersonRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Assisted person is not exists"));

        List<AssistedPersonTag> tags =
                assistedPersonTagRepository.findByAssistedPerson(assistedPerson);

        return mapper.toResponse(assistedPerson, tags);
    }

    private List<AssistedPersonTag> createTags(AssistedPerson person, List<Long> tagIds) {
        return tagRepository.findAllById(tagIds)
                .stream()
                .map(tag -> new AssistedPersonTag(person, tag))
                .toList();
    }

}
