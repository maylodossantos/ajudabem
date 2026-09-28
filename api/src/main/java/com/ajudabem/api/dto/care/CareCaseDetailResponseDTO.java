package com.ajudabem.api.dto.care;

import java.util.List;

public record CareCaseDetailResponseDTO(CareCaseResponseDTO person, List<CareRecordResponseDTO> records) { }
