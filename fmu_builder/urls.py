from django.conf.urls import url
import fmu_builder.website.views

urlpatterns = [
    url(r"^$", fmu_builder.website.views.UploadView.as_view()),
    url(
        r"^fmubuilder/$",
        fmu_builder.website.views.UploadView.as_view(),
        name="upload",
    ),
    url(
        r"^fmubuilder$",
        fmu_builder.website.views.UploadView.as_view(),
        name="upload",
    ),
    url(
        r"^fmubuilder/(?P<uuid>[a-z0-9-]{36})/$",
        fmu_builder.website.views.UploadView.as_view(),
        name="result",
    ),
    url(
        r"^fmubuilder/download/(?P<uuid>[a-z0-9-]{36})/$",
        fmu_builder.website.views.DownloadView.as_view(),
        name="download",
    ),
]
