abstract final class ServerMessages {
  static const userConflicts = {
    'Email is using': 'E-mail já cadastrado.',
    'CPF is using': 'CPF já cadastrado em outra conta.',
  };

  static const organization = {
    'Organization already submitted': 'Sua ONG já foi enviada para validação.',
    'CNPJ is using': 'Este CNPJ já está cadastrado em outra ONG.',
    'Organization can only be resubmitted 7 days after the rejection':
        'Aguarde 7 dias após a reprovação para solicitar uma nova validação.',
    'Organization was already reviewed': 'Esta solicitação já foi analisada.',
    'Admins cannot register an organization':
        'Administradores não podem cadastrar uma ONG.',
    'All required documents must be sent':
        'Envie todos os documentos obrigatórios.',
    'Documents must be PDF files up to 10 MB':
        'Os documentos precisam ser arquivos PDF de até 10 MB.',
    'File is too large': 'Os documentos precisam ter no máximo 10 MB cada.',
  };
}
