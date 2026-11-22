enum NewsCategory {
  community('COMMUNITY', 'Comunidade'),
  health('HEALTH', 'Saúde'),
  education('EDUCATION', 'Educação'),
  food('FOOD', 'Alimentação'),
  volunteering('VOLUNTEERING', 'Voluntariado'),
  events('EVENTS', 'Eventos'),
  other('OTHER', 'Outros');

  const NewsCategory(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static NewsCategory fromApi(String? value) => values.firstWhere(
    (category) => category.apiValue == value,
    orElse: () => other,
  );
}
