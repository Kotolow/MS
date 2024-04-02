from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Manga, Chapter, UserManga, History, UserGenre

class ChapterSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chapter
        fields = ['chapter_id', 'url', 'title']

class MangaSerializer(serializers.ModelSerializer):
    chapters = ChapterSerializer(many=True, read_only=True)

    class Meta:
        model = Manga
        fields = ['id', 'url', 'title', 'cover', 'chapters_count', 'status', 'genres', 'year', 'description', 'chapters']

class MangaShortSerializer(serializers.ModelSerializer):
    class Meta:
        model = Manga
        fields = ['id', 'url', 'title', 'chapters_count', 'status', 'description']

class UserMangaSerializer(serializers.ModelSerializer):
    manga = MangaShortSerializer(read_only=True)

    class Meta:
        model = UserManga
        fields = ['id', 'manga', 'is_favorite', 'status']

class HistorySerializer(serializers.ModelSerializer):
    manga = MangaShortSerializer(read_only=True)
    chapter = ChapterSerializer(read_only=True)

    class Meta:
        model = History
        fields = ['id', 'manga', 'chapter']

class UserGenreSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserGenre
        fields = ['id', 'genre']

class UserRegistrationSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('username', 'password')
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            password=validated_data['password']
        )
        return user

