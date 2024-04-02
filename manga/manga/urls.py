from django.contrib import admin
from django.urls import path, include
from rest_framework import routers
from rest_framework.authtoken.views import obtain_auth_token
from backend.views import (MangaViewSet, UserMangaViewSet, HistoryViewSet, UserGenreViewSet,
                           RecommendationViewSet, UserRegistrationView, UserStatsViewSet)

router = routers.DefaultRouter()
router.register(r'mangas', MangaViewSet, basename='manga')
router.register(r'user-mangas', UserMangaViewSet, basename='user-manga')
router.register(r'history', HistoryViewSet, basename='history')
router.register(r'user-genres', UserGenreViewSet, basename='user-genre')
router.register(r'recommendations', RecommendationViewSet, basename='recommendation')
router.register(r'user-stats', UserStatsViewSet, basename='user-stats')

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
    path('api-token-auth/', obtain_auth_token, name='api_token_auth'),
    path('api-registration/', UserRegistrationView.as_view(), name='api_registration'),
]
