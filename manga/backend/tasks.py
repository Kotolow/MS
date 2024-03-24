from celery import shared_task
from .models import Manga, Chapter, MangaGenre
from .parser import MangapoiskParser

@shared_task
def update_manga_details():
    parser = MangapoiskParser()
    for manga in Manga.objects.all():
        manga_details = parser.get_manga_details(manga.url)
        if manga_details:
            manga_info = manga_details['info']
            manga.cover = manga_info['cover']
            manga.chapters_count = manga_info['chapters_count']
            manga.status = manga_info['status']
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

            update_manga_genres.delay(manga.id)

@shared_task
def update_manga_genres(manga_id):
    manga = Manga.objects.get(id=manga_id)
    parser = MangapoiskParser()
    manga_details = parser.get_manga_details(manga.url)
    if manga_details:
        manga_info = manga_details['info']
        manga.genres = ', '.join(manga_info['genres'])
        manga.save()

        manga.manga_genres.all().delete()
        for genre in manga_info['genres']:
            MangaGenre.objects.create(manga=manga, genre=genre)
