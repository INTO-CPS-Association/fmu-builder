from django import forms
from django.core import urlresolvers
from django.http import HttpResponse
from django.http import HttpResponseNotAllowed
from django.utils import html
from django.views.generic import FormView
from django.views.generic import TemplateView
import os.path
import subprocess

from .models import BuildLog


CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))
SCRIPT_PATH = os.path.join(CURRENT_DIR, "../../fmu-compiler/compile-fmu.sh")
# SCRIPT_PATH = os.path.join(CURRENT_DIR, "test.sh")


class UploadForm(forms.Form):
    file = forms.FileField()


class UploadView(FormView):
    template_name = "upload.html"
    form_class = UploadForm

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        uuid = self.kwargs.get("uuid", None)
        if uuid is None:
            return context
        build_log = BuildLog.objects.get(uuid=uuid)
        context["command_output"] = html.escape(build_log.command_output)
        context["download_url"] = urlresolvers.reverse(
            "download",
            kwargs={"uuid": uuid},
        )
        return context

    def form_valid(self, form):
        input_file = form.cleaned_data["file"]
        input_file_path = input_file.temporary_file_path()
        input_file_name = input_file.name
        command = [SCRIPT_PATH, input_file_path, input_file_name]
        command_output = subprocess.check_output(command).decode()
        download_file_path = command_output.split("\n")[-2]
        build_log = BuildLog.objects.create(
            command_output=command_output,
            output_file_path=download_file_path,
        )
        self.success_url = urlresolvers.reverse(
            "result",
            kwargs={"uuid": build_log.uuid},
        )
        return super().form_valid(form)


class DownloadView(TemplateView):
    def get(self, request, *args, **kwargs):
        uuid = self.kwargs.get("uuid", None)
        if uuid is None:
            return HttpResponseNotAllowed()
        build_log = BuildLog.objects.get(uuid=uuid)
        file_path = build_log.output_file_path
        with open(file_path, "rb") as f:
            data = f.read()
        response = HttpResponse(data, content_type="application/zip")
        ascii_file_name = \
            file_path.encode(encoding="ascii", errors="replace").decode()
        response["Content-Disposition"] = \
            'attachment; filename="{}"'.format(ascii_file_name)
        return response
