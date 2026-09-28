package com.ajudabem.api.infra;

import com.ajudabem.api.dto.error.ErrorResponseDTO;
import com.ajudabem.api.dto.error.ValidationErrorResponseDTO;
import com.ajudabem.api.exceptions.ActionFullException;
import com.ajudabem.api.exceptions.AlreadyAppliedException;
import com.ajudabem.api.exceptions.AssistedPersonNotFoundException;
import com.ajudabem.api.exceptions.CampaignNotFoundException;
import com.ajudabem.api.exceptions.NotificationNotFoundException;
import com.ajudabem.api.exceptions.TagAlreadyExistsException;
import com.ajudabem.api.exceptions.TagNotFoundException;
import com.ajudabem.api.exceptions.InitiativeClosedException;
import com.ajudabem.api.exceptions.VolunteerActionNotFoundException;
import com.ajudabem.api.exceptions.VolunteerApplicationNotFoundException;
import com.ajudabem.api.exceptions.CaseAlreadyAssumedException;
import com.ajudabem.api.exceptions.CaseClosedException;
import com.ajudabem.api.exceptions.CnpjAlreadyExistsException;
import com.ajudabem.api.exceptions.CpfAlreadyExistsException;
import com.ajudabem.api.exceptions.EmailAlreadyExistsException;
import com.ajudabem.api.exceptions.ForbiddenActionException;
import com.ajudabem.api.exceptions.HelpPointNotFoundException;
import com.ajudabem.api.exceptions.InvalidDocumentFileException;
import com.ajudabem.api.exceptions.MissingOrganizationDocumentsException;
import com.ajudabem.api.exceptions.InvalidPasswordException;
import com.ajudabem.api.exceptions.InvalidResetTokenException;
import com.ajudabem.api.exceptions.InvalidTokenException;
import com.ajudabem.api.exceptions.InvalidVerificationCodeException;
import com.ajudabem.api.exceptions.NewsNotFoundException;
import com.ajudabem.api.exceptions.OrganizationAlreadySubmittedException;
import com.ajudabem.api.exceptions.OrganizationDocumentNotFoundException;
import com.ajudabem.api.exceptions.OrganizationNotFoundException;
import com.ajudabem.api.exceptions.OrganizationNotPendingException;
import com.ajudabem.api.exceptions.OrganizationResubmissionTooSoonException;
import com.ajudabem.api.exceptions.PasswordMismatchException;
import com.ajudabem.api.exceptions.UserAlreadyDeletedException;
import com.ajudabem.api.exceptions.UserNotFoundException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.util.LinkedHashMap;
import java.util.Map;

@ControllerAdvice
public class RestExceptionHandler extends ResponseEntityExceptionHandler {

    @ExceptionHandler({
            UserNotFoundException.class,
            AssistedPersonNotFoundException.class,
            NewsNotFoundException.class,
            OrganizationNotFoundException.class,
            OrganizationDocumentNotFoundException.class,
            HelpPointNotFoundException.class,
            CampaignNotFoundException.class,
            TagNotFoundException.class,
            NotificationNotFoundException.class,
            VolunteerActionNotFoundException.class,
            VolunteerApplicationNotFoundException.class
    })
    public ResponseEntity<ErrorResponseDTO> notFoundHandler(RuntimeException exception) {
        return error(HttpStatus.NOT_FOUND, exception);
    }

    @ExceptionHandler({
            InvalidPasswordException.class,
            InvalidTokenException.class,
            InvalidVerificationCodeException.class,
            InvalidResetTokenException.class
    })
    public ResponseEntity<ErrorResponseDTO> unauthorizedHandler(RuntimeException exception) {
        return error(HttpStatus.UNAUTHORIZED, exception);
    }

    @ExceptionHandler(ForbiddenActionException.class)
    public ResponseEntity<ErrorResponseDTO> forbiddenHandler(RuntimeException exception) {
        return error(HttpStatus.FORBIDDEN, exception);
    }

    @ExceptionHandler({
            EmailAlreadyExistsException.class,
            CpfAlreadyExistsException.class,
            CaseAlreadyAssumedException.class,
            CaseClosedException.class,
            InitiativeClosedException.class,
            TagAlreadyExistsException.class,
            AlreadyAppliedException.class,
            ActionFullException.class,
            CnpjAlreadyExistsException.class,
            OrganizationAlreadySubmittedException.class,
            OrganizationResubmissionTooSoonException.class,
            OrganizationNotPendingException.class,
            UserAlreadyDeletedException.class
    })
    public ResponseEntity<ErrorResponseDTO> conflictHandler(RuntimeException exception) {
        return error(HttpStatus.CONFLICT, exception);
    }

    @ExceptionHandler({
            PasswordMismatchException.class,
            InvalidDocumentFileException.class,
            MissingOrganizationDocumentsException.class
    })
    public ResponseEntity<ErrorResponseDTO> badRequestHandler(RuntimeException exception) {
        return error(HttpStatus.BAD_REQUEST, exception);
    }

    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(
            MethodArgumentNotValidException exception,
            HttpHeaders headers,
            HttpStatusCode status,
            WebRequest request) {

        Map<String, String> errors = new LinkedHashMap<>();
        for (FieldError fieldError : exception.getBindingResult().getFieldErrors()) {
            errors.put(fieldError.getField(), fieldError.getDefaultMessage());
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ValidationErrorResponseDTO(
                        HttpStatus.BAD_REQUEST.value(),
                        "Erro de validação",
                        errors
                ));
    }

    @Override
    protected ResponseEntity<Object> handleMaxUploadSizeExceededException(
            MaxUploadSizeExceededException exception,
            HttpHeaders headers,
            HttpStatusCode status,
            WebRequest request) {
        return ResponseEntity.status(HttpStatus.PAYLOAD_TOO_LARGE)
                .body(ErrorResponseDTO.of(HttpStatus.PAYLOAD_TOO_LARGE, "File is too large"));
    }

    private ResponseEntity<ErrorResponseDTO> error(HttpStatus status, RuntimeException exception) {
        return ResponseEntity.status(status).body(ErrorResponseDTO.of(status, exception.getMessage()));
    }
}
