"""
URL configuration for rtt_backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from rest_framework import routers
from django.contrib import admin
from django.urls import include, path
from api import views

apiRouter = routers.SimpleRouter()
apiRouter.register(r'goals', views.GoalViews)

urlpatterns = [
    path('', include(apiRouter.urls)),
    path('friends/', views.FriendView.as_view()),
    path('register/', views.UserView.as_view()),
    path('admin/', admin.site.urls),
]