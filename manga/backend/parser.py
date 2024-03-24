import requests
from bs4 import BeautifulSoup
import math

class Parser:
    def __init__(self, base_url):
        self.base_url = base_url

    def get_search_results(self, search_query):
        raise NotImplementedError("Метод get_search_results должен быть реализован в подклассе")

    def get_info(self, manga_url):
        raise NotImplementedError("Метод get_info должен быть реализован в подклассе")

    def get_chapters(self, manga_url, chapters_count):
        raise NotImplementedError("Метод get_chapters должен быть реализован в подклассе")

    def get_manga_details(self, manga_url):
        raise NotImplementedError("Метод get_manga_details должен быть реализован в подклассе")

    def get_chapter_images(self, chapter_url):
        raise NotImplementedError("Метод get_chapter_images должен быть реализован в подклассе")

class MangapoiskParser(Parser):
    def __init__(self):
        super().__init__("https://mangapoisk.net")

    def get_search_results(self, search_query):
        url = f"{self.base_url}/search?q={search_query}"
        try:
            response = requests.get(url)
            response.raise_for_status()
            soup = BeautifulSoup(response.text, 'html.parser')

            results = []
            manga_articles = soup.select('div.row > div.card > div > article')
            for article in manga_articles:
                manga_link = article.select_one('a[href^="/manga/"]')
                if manga_link:
                    manga_url = f"{self.base_url}{manga_link['href']}"
                    manga_title = manga_link.get('title', manga_link.text.strip())
                    manga_cover = article.select_one('img')['src']

                    results.append({
                        'title': manga_title,
                        'url': manga_url,
                        'cover': manga_cover
                    })

            return results

        except requests.exceptions.RequestException as e:
            print(f"Error in getting target search result: {e}")
            return []

    def get_info(self, manga_url):
        try:
            response = requests.get(manga_url)
            response.raise_for_status()
            soup = BeautifulSoup(response.text, 'html.parser')
            manga_cover = soup.select_one('button.w-full > img')['src']
            manga_info_div = soup.select_one('div.py-2 > div')

            if manga_info_div:
                manga_title = manga_info_div.select_one('h2.manga-alt-name').text.strip()
                manga_chapters_count = manga_info_div.select('span:nth-of-type(1)')[1].text.strip().replace('Глав: ', '')
                manga_rating = manga_info_div.select_one('b.ml-1').text.strip()
                manga_status = manga_info_div.select_one('span:nth-of-type(2)').text.strip().replace('Статус: ', '')
                manga_genres = [genre.text.strip() for genre in manga_info_div.select_one('span:nth-of-type(3)').select('a')]
                manga_year = manga_info_div.select_one('span:nth-of-type(4) > a').text.strip()
                manga_description = manga_info_div.select_one('div.manga-description').text.strip()

                return {
                    'title': manga_title,
                    'cover': manga_cover,
                    'chapters_count': int(manga_chapters_count),
                    'rating': manga_rating,
                    'status': manga_status,
                    'genres': manga_genres,
                    'year': manga_year,
                    'description': manga_description
                }

        except (requests.exceptions.RequestException, AttributeError) as e:
            print(f"Error in getting target info: {e}")
            return None

    def get_chapters(self, manga_url, chapters_count):
        try:
            chapters = []
            pages_count = math.ceil(chapters_count / 50)

            for page in range(1, pages_count + 1):
                response = requests.get(f"{manga_url}?tab=chapters&page={page}")
                response.raise_for_status()
                soup = BeautifulSoup(response.text, 'html.parser')

                chapters_ul = soup.select_one('div.py-2 > div > ul')

                if chapters_ul:
                    for chapter_li in chapters_ul.select('li')[1:]:
                        chapter_link = chapter_li.select_one('span:nth-of-type(1) > a')
                        if not chapter_link:
                            break
                        chapter_url = f"{self.base_url}{chapter_link['href']}"
                        chapter_title = f"{chapter_link.text.strip()}"
                        chapters.append({'url': chapter_url, 'title': chapter_title})

            return reversed(chapters)

        except (requests.exceptions.RequestException, AttributeError) as e:
            print(f"Error in getting target chapters: {e}")
            return []

    def get_manga_details(self, manga_url):
        manga_info = self.get_info(manga_url)
        if manga_info:
            chapters = self.get_chapters(manga_url, manga_info['chapters_count'])
            if chapters:
                return {
                    'info': manga_info,
                    'chapters': chapters
                }
        return None

    def get_chapter_images(self, chapter_url):
        try:
            response = requests.get(chapter_url)
            response.raise_for_status()
            soup = BeautifulSoup(response.text, 'html.parser')

            images_div = soup.select_one('div.py-4 > div.pt-4')

            if images_div:
                images = []
                for img in images_div.select('img'):
                    image_data = {
                        'src': img['src'],
                        'data-number': img.get('data-number', ''),
                        'title': img.get('title', '')
                    }
                    images.append(image_data)

                return images

        except (requests.exceptions.RequestException, AttributeError) as e:
            print(f"Error in getting target pages: {e}")
            return []
