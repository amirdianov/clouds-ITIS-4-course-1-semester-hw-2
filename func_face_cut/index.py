import json
import os
import boto3
import uuid
import io
from PIL import Image



def handler(event, context):
    message = event.get("messages").pop()
    data_from_body = message.get("details").get("message").get("body")
    
    data = json.loads(data_from_body)
    image_id = data.get("obj_id")
    face = data.get("face")
    
    client = boto3.client(
        's3',
        endpoint_url="https://storage.yandexcloud.net",
    )
    image = Image.open(f"/function/storage/vvot25-photo/{image_id}")

    face_image = image.crop(
        (face[0], face[1], face[0]+face[2], face[1] + face[3])
    )

    buffer = io.BytesIO()
    face_image.save(buffer, format="JPEG")
    buffer.seek(0)

    client.put_object(
        Bucket="vvot25-faces",
        Key=f"undefined_{image_id}_{uuid.uuid4().hex}.jpg",
        Body=buffer,
        ContentType="image/jpeg",
    )

    return {
        'statusCode': 200,
        'body': None
    }