API Endpoints:

1. **Mangas**:
   - `/api/mangas/` (GET)
     - GET: retrieve a list of all mangas in the system.
   - `/api/mangas/{id}/` (GET, PUT, PATCH, DELETE)
     - GET: retrieve details of a specific manga by its `id`.
   - `/api/mangas/search/?q={search_query}` (GET)
     - Search for mangas by title or description.
   - `/api/mangas/{id}/chapter_images/?chapter_id={chapter_id}` (GET)
     - Retrieve a list of images for the specified manga chapter.

   **Examples**:
   - GET `/api/mangas/`: retrieve a list of all mangas.
   - GET `/api/mangas/1/`: retrieve details of the manga with `id=1`.
   - GET `/api/mangas/search/?q=naruto`: search for mangas containing "naruto" in the title or description.
   - GET `/api/mangas/1/chapter_images/?chapter_id=3`: retrieve images for chapter 3 of the manga with `id=1`.

2. **User Mangas**:
   - `/api/user-mangas/` (GET, POST)
     - GET: retrieve the user's list of mangas (authentication required).
     - POST: add a new manga for the user (authentication required).

   **Examples**:
   - GET `/api/user-mangas/` (authentication required): retrieve the user's list of mangas.
   - POST `/api/user-mangas/` (authentication required):
     ```json
     {
       "manga": 1,
       "is_favorite": true,
       "status": "reading"
     }
     ```

3. **History**:
   - `/api/history/` (GET, POST)
     - GET: retrieve the user's reading history (authentication required).
     - POST: add a new entry to the history (authentication required).

   **Examples**:
   - GET `/api/history/` (authentication required): retrieve the user's reading history.
   - POST `/api/history/` (authentication required):
     ```json
     {
       "manga": 1,
       "chapter": 3
     }
     ```

4. **User Genres**:
   - `/api/user-genres/` (POST)
     - POST: add new genres for the user (authentication required).

   **Examples**:
   - POST `/api/user-genres/` (authentication required):
     ```json
     {
       "genres": "adventure, fantasy, romance"
     }
     ```

5. **Recommendations**:
   - `/api/recommendations/` (GET)
     - GET: retrieve a list of recommended mangas for the user (authentication required).

   **Examples**:
   - GET `/api/recommendations/` (authentication required): retrieve a list of recommended mangas.

Application Features:

1. **Manga Search**: Users can search for mangas by title or description using the endpoint `/api/mangas/search/`.

2. **Favorites**: Users can add mangas to their favorites list via the endpoint `/api/user-mangas/`. They can also remove mangas from their favorites.

3. **Reading History**: The application tracks the user's reading history. Users can add new entries to their history via the endpoint `/api/history/`.

4. **User Manga Status**: Users can set the status for each manga in their list: "reading", "planned", or "completed". This is done through the endpoint `/api/user-mangas/`.

5. **Favorite Genres**: Users can specify their favorite genres via the endpoint `/api/user-genres/`. This information is used for the recommendation system.

6. **Recommendation System**: Based on the user's favorite genres and the mangas they have already read, the system recommends new mangas that might interest them. Recommendations can be retrieved through the endpoint `/api/recommendations/`.

7. **Periodic Data Update**: The application periodically updates information about mangas, chapters, and genres using a background task with Celery.

8. **Authorization**: Most endpoints require user authentication. Users can obtain an authentication token via the endpoint `/api-token-auth/`.

9. **Profile**: Users can log out and view their manga reading statistics through the endpoint `/api/user-stats/stats`.