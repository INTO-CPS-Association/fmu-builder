from django import forms
from django.http import HttpResponse
from django.views.generic import FormView
import os.path
import subprocess


CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))
SCRIPT_PATH = os.path.join(CURRENT_DIR, "test.sh")


class UploadForm(forms.Form):
    file = forms.FileField()


class UploadView(FormView):
    template_name = "upload.html"
    form_class = UploadForm

    def form_valid(self, form):
        input_file = form.cleaned_data["file"]
        input_file_path = input_file.temporary_file_path()
        input_file_name = input_file.name
        command = [SCRIPT_PATH, input_file_path]
        output_file_path = subprocess.check_output(command).strip()
        with open(output_file_path, "rb") as f:
            data = f.read()
        response = HttpResponse(data, content_type="application/zip")
        ascii_file_name = \
            input_file_name.encode(encoding="ascii", errors="replace").decode()
        response["Content-Disposition"] = \
            'attachment; filename="{}.zip"'.format(ascii_file_name)
        return response
