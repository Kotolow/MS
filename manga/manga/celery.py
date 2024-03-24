import os
from celery import Celery

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'manga.settings')

celery_app = Celery('manga')
celery_app.config_from_object('django.conf:settings', namespace='CELERY')
celery_app.autodiscover_tasks()

celery_app.conf.beat_schedule = {
    'update_manga_details': {
        'task': 'backend.tasks.update_manga_details',
        'schedule': 5.0,
    },
}
