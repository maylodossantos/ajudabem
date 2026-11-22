import 'package:ajuda_bem/modules/news/domain/entities/news_article.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_category.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_form_params.dart';
import 'package:ajuda_bem/modules/news/domain/repositories/news_repository.dart';
import 'package:ajuda_bem/modules/profile/domain/entities/user_profile.dart';
import 'package:ajuda_bem/modules/profile/domain/repositories/profile_repository.dart';

const winterArticle = NewsArticle(
  id: 1,
  title: 'Campanha do inverno',
  subtitle: 'Ajude quem precisa',
  content: 'Texto completo.',
  coverImage: null,
  authorName: 'ONG Esperança',
  city: 'Cascavel',
  state: 'PR',
);

NewsArticle articleWith({
  required int id,
  required String title,
  NewsCategory category = NewsCategory.other,
}) => NewsArticle(
  id: id,
  title: title,
  subtitle: '',
  content: 'Texto.',
  coverImage: null,
  authorName: 'Admin',
  category: category,
);

class FakeNewsRepository implements NewsRepository {
  FakeNewsRepository({this.articles = const [winterArticle]});

  final List<NewsArticle> articles;

  @override
  Future<List<NewsArticle>> getAll(String? token) async => articles;

  @override
  Future<NewsArticle> create(NewsFormParams params, String token) {
    throw UnimplementedError();
  }

  @override
  Future<NewsArticle> update(int id, NewsFormParams params, String token) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(int id, String token) async {}
}

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({required this.role});

  final String role;

  @override
  Future<UserProfile> getCurrentUser(String token) async {
    return UserProfile(
      id: 1,
      name: 'Test User',
      email: 'test@ajudabem.com',
      phone: '',
      role: role,
    );
  }

  @override
  Future<UserProfile> updateProfile(
    String token, {
    String? name,
    String? phone,
    String? profileImage,
    String? cpf,
    DateTime? birthDate,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAccount(String token) {
    throw UnimplementedError();
  }
}
