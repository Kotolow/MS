import pandas as pd
from .models import Manga, UserManga, History
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import linear_kernel


class MangaRecommender:
    def __init__(self):
        self.manga_data = None
        self.tfidf_matrix = None
        self.cosine_sim = None
        self.tfidf_vectorizer = None

    def load_data(self):
        manga_queryset = Manga.objects.prefetch_related('manga_genres')
        manga_data = []
        for manga in manga_queryset:
            genres = ', '.join([genre.genre for genre in manga.manga_genres.all()])
            manga_data.append({
                'id': manga.id,
                'title': manga.title,
                'genres': genres
            })
        self.manga_data = pd.DataFrame(manga_data)

    def preprocess_data(self):
        self.tfidf_vectorizer = TfidfVectorizer(stop_words='english')
        self.tfidf_matrix = self.tfidf_vectorizer.fit_transform(self.manga_data['genres'])
        self.cosine_sim = linear_kernel(self.tfidf_matrix, self.tfidf_matrix)

    def get_recommendations(self, user):
        user_genres = user.favorite_genres.values_list('genre', flat=True)
        user_mangas = UserManga.objects.filter(user=user).values_list('manga_id', flat=True)
        user_history = History.objects.filter(user=user).values_list('manga_id', flat=True)
        read_mangas = list(set(user_mangas) | set(user_history))

        user_genres_str = ', '.join(user_genres)
        tfidf_matrix_user = self.tfidf_vectorizer.transform([user_genres_str])
        cosine_sim_user = linear_kernel(tfidf_matrix_user, self.tfidf_matrix)

        recommended_manga_indices = cosine_sim_user.argsort()[0][::-1]
        recommended_manga_ids = [self.manga_data.iloc[index]['id'] for index in recommended_manga_indices if
                                 index not in read_mangas]

        recommended_mangas = Manga.objects.exclude(id__in=read_mangas).filter(id__in=recommended_manga_ids)

        return recommended_mangas
