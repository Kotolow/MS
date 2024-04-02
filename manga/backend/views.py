from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from django.contrib.auth.models import User
from .models import Manga, Chapter, UserManga, History, UserGenre
from .serializers import (MangaSerializer, UserMangaSerializer, HistorySerializer, UserGenreSerializer,
                          MangaShortSerializer, UserRegistrationSerializer)
from .parser import MangapoiskParser
from .recommender import MangaRecommender

class MangaViewSet(viewsets.ModelViewSet):
    queryset = Manga.objects.filter(chapters__isnull=False).distinct()
    serializer_class = MangaSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['get'])
    def search(self, request):
        search_query = request.query_params.get('q', None)
        if search_query:
            parser = MangapoiskParser()
            search_results = parser.get_search_results(search_query)
            manga_ids = [self.get_or_create_manga(result) for result in search_results]
            queryset = Manga.objects.filter(id__in=manga_ids, chapters__isnull=False).distinct()
            serializer = MangaShortSerializer(queryset, many=True)
            return Response(serializer.data)
        else:
            return Response({"error": "Search query parameter is required."}, status=status.HTTP_400_BAD_REQUEST)


    @action(detail=True, methods=['get'])
    def chapter_images(self, request, pk=None):
        manga = self.get_object()
        chapter_id = request.query_params.get('chapter_id')
        chapter = get_object_or_404(Chapter, chapter_id=chapter_id, manga=manga)
        parser = MangapoiskParser()
        images = parser.get_chapter_images(chapter.url)
        return Response(images)

    def get_or_create_manga(self, result):
        manga, created = Manga.objects.get_or_create(
            title=result['title'],
            defaults={
                'url': result['url'],
                'cover': result['cover'],
                'chapters_count': 0,
                'status': '',
                'genres': '',
                'year': '',
                'description': ''
            }
        )
        if created:
            parser = MangapoiskParser()
            manga_details = parser.get_manga_details(result['url'])
            if manga_details:
                manga_info = manga_details['info']
                manga.cover = manga_info['cover']
                manga.chapters_count = manga_info['chapters_count']
                manga.status = manga_info['status']
                manga.genres = ', '.join(manga_info['genres'])
                manga.year = manga_info['year']
                manga.description = manga_info['description']
                manga.save()

                Chapter.objects.filter(manga=manga).delete()
                for index, chapter in enumerate(manga_details['chapters'], start=1):
                    Chapter.objects.get_or_create(
                        manga=manga,
                        chapter_id=index,
                        url=chapter['url'],
                        title=chapter['title']
                    )
        return manga.id

class UserMangaViewSet(viewsets.ModelViewSet):
    queryset = UserManga.objects.all()
    serializer_class = UserMangaSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return UserManga.objects.filter(user=self.request.user, manga__chapters__isnull=False).distinct()

    def perform_create(self, serializer):
        manga = get_object_or_404(Manga, id=self.request.data.get('manga'))
        user_manga, created = UserManga.objects.get_or_create(
            user=self.request.user,
            manga=manga,
            defaults=serializer.validated_data
        )
        if not created:
            serializer.update(user_manga, serializer.validated_data)

class HistoryViewSet(viewsets.ModelViewSet):
    queryset = History.objects.all()
    serializer_class = HistorySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return History.objects.filter(user=self.request.user, manga__chapters__isnull=False).distinct()

    def perform_create(self, serializer):
        manga = get_object_or_404(Manga, id=self.request.data.get('manga'))
        chapter_id = self.request.data.get('chapter')
        chapter = get_object_or_404(Chapter, chapter_id=chapter_id, manga=manga)
        history, created = History.objects.get_or_create(
            user=self.request.user,
            manga=manga,
            chapter=chapter,
            defaults=serializer.validated_data
        )
        if not created:
            serializer.update(history, serializer.validated_data)


class UserGenreViewSet(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated]

    def create(self, request):
        user = request.user
        genres_str = request.data.get('genres', '')
        genres = [genre.strip() for genre in genres_str.split(',') if genre.strip()]

        if not genres:
            return Response({'error': 'No genres provided.'}, status=status.HTTP_400_BAD_REQUEST)

        existing_genres = list(user.favorite_genres.values_list('genre', flat=True))
        new_genres = [genre for genre in genres if genre not in existing_genres]

        user_genres = [UserGenre(user=user, genre=genre) for genre in new_genres]
        UserGenre.objects.bulk_create(user_genres)

        user_genres_data = UserGenreSerializer(user.favorite_genres.all(), many=True).data
        return Response(user_genres_data, status=status.HTTP_201_CREATED)

class RecommendationViewSet(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated]

    def list(self, request):
        user = request.user
        recommender = MangaRecommender()
        recommender.load_data()
        recommender.preprocess_data()
        recommended_mangas = recommender.get_recommendations(user)
        filtered_mangas = [manga for manga in recommended_mangas if manga.chapters.exists()]
        serializer = MangaShortSerializer(filtered_mangas, many=True)
        return Response(serializer.data)

class UserRegistrationView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserStatsViewSet(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['get'])
    def stats(self, request):
        user = request.user
        reading_count = UserManga.objects.filter(user=user, status='reading', manga__chapters__isnull=False).distinct().count()
        plan_to_read_count = UserManga.objects.filter(user=user, status='plan_to_read', manga__chapters__isnull=False).distinct().count()
        completed_count = UserManga.objects.filter(user=user, status='completed', manga__chapters__isnull=False).distinct().count()
        favorite_count = UserManga.objects.filter(user=user, is_favorite=True, manga__chapters__isnull=False).distinct().count()
        chapters_read_count = History.objects.filter(user=user, manga__chapters__isnull=False).distinct().count()

        stats_data = {
            'username': user.username,
            'reading_count': reading_count,
            'plan_to_read_count': plan_to_read_count,
            'completed_count': completed_count,
            'favorite_count': favorite_count,
            'chapters_read_count': chapters_read_count
        }

        return Response(stats_data)
