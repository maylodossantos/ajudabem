package com.ajudabem.api.dto.organization;

import com.ajudabem.api.infra.validation.ValidCnpj;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record OrganizationRequestDTO(
        @NotBlank(message = "Razão social é obrigatória")
        @Size(max = 150, message = "Razão social deve ter no máximo 150 caracteres")
        String corporateName,

        @NotBlank(message = "Nome fantasia é obrigatório")
        @Size(max = 150, message = "Nome fantasia deve ter no máximo 150 caracteres")
        String tradeName,

        @NotBlank(message = "CNPJ é obrigatório")
        @ValidCnpj
        String cnpj,

        @NotBlank(message = "Área de atuação é obrigatória")
        @Size(max = 100, message = "Área de atuação deve ter no máximo 100 caracteres")
        String activityArea,

        @NotBlank(message = "Endereço é obrigatório")
        @Size(max = 255, message = "Endereço deve ter no máximo 255 caracteres")
        String street,

        @NotBlank(message = "Número é obrigatório")
        @Size(max = 20, message = "Número deve ter no máximo 20 caracteres")
        String number,

        @Size(max = 100, message = "Bairro deve ter no máximo 100 caracteres")
        String neighborhood,

        @NotBlank(message = "Cidade é obrigatória")
        @Size(max = 100, message = "Cidade deve ter no máximo 100 caracteres")
        String city,

        @NotBlank(message = "Estado é obrigatório")
        @Pattern(regexp = "[A-Za-z]{2}", message = "Estado deve ser a sigla da UF")
        String state,

        @NotBlank(message = "CEP é obrigatório")
        @Pattern(regexp = "\\d{5}-?\\d{3}", message = "CEP inválido")
        String zipCode,

        @Size(max = 255, message = "Site deve ter no máximo 255 caracteres")
        String website,

        @Size(max = 100, message = "Instagram deve ter no máximo 100 caracteres")
        String instagram,

        @NotNull(message = "É necessário aceitar os Termos de Uso e a Política de Privacidade")
        @AssertTrue(message = "É necessário aceitar os Termos de Uso e a Política de Privacidade")
        Boolean acceptedTerms,

        @NotNull(message = "É necessário autorizar o tratamento dos dados conforme a LGPD")
        @AssertTrue(message = "É necessário autorizar o tratamento dos dados conforme a LGPD")
        Boolean acceptedDataProcessing,

        @NotNull(message = "É necessário confirmar que as informações são verdadeiras")
        @AssertTrue(message = "É necessário confirmar que as informações são verdadeiras")
        Boolean declaredTruthful
) { }
