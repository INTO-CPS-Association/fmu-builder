from django.db import models

import uuid


class BuildLog(models.Model):
    command_output = models.TextField(blank=False)
    output_file_path = models.TextField(blank=False)
    uuid = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
