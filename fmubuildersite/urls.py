"""fmubuildersite URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
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
from django.contrib import admin
from django.urls import path
from django.conf.urls import url


from builderapp.views import UploadView,DownloadView

urlpatterns = [
    url(r"^$", UploadView.as_view()),
    url(
        r"^fmubuilder/$",
        UploadView.as_view(),
        name="upload",
    ),
    url(
        r"^fmubuilder$",
        UploadView.as_view(),
        name="upload",
    ),
    url(
        r"^fmubuilder/(?P<uuid>[a-z0-9-]{36})/$",
        UploadView.as_view(),
        name="result",
    ),
    url(
        r"^fmubuilder/download/(?P<uuid>[a-z0-9-]{36})/$",
        DownloadView.as_view(),
        name="download",
    ),
]