from django.db import models
from django.contrib.auth.models import User

class Manga(models.Model):
    url = models.URLField(blank=False)
    title = models.CharField(max_length=255)
    cover = models.URLField()
    chapters_count = models.IntegerField()
    status = models.CharField(max_length=50)
    genres = models.CharField(max_length=255)
    year = models.CharField(max_length=4)
    description = models.TextField()

class Chapter(models.Model):
    manga = models.ForeignKey(Manga, on_delete=models.CASCADE, related_name='chapters')
    chapter_id = models.IntegerField()
    url = models.URLField()
    title = models.CharField(max_length=255)

class UserManga(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    manga = models.ForeignKey(Manga, on_delete=models.CASCADE)
    is_favorite = models.BooleanField(default=False)
    status = models.CharField(max_length=20, choices=(
        ('not_reading', 'Не читаю'),
        ('reading', 'Читаю'),
        ('plan_to_read', 'В планах'),
        ('completed', 'Прочитано')
    ), default='plan_to_read')

class History(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    manga = models.ForeignKey(Manga, on_delete=models.CASCADE)
    chapter = models.ForeignKey(Chapter, on_delete=models.CASCADE)

class UserGenre(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='favorite_genres')
    genre = models.CharField(max_length=50)

class MangaGenre(models.Model):
    manga = models.ForeignKey(Manga, on_delete=models.CASCADE, related_name='manga_genres')
    genre = models.CharField(max_length=50)