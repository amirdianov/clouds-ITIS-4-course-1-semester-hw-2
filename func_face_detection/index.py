import json

import cv2
import boto3
import os


def handler(event, context):
    message = event.get("messages").pop()
    obj_id = message.get("details").get("object_id")

    photo_path = f"/function/storage/vvot25-photo/{obj_id}"

    image = cv2.imread(filename=photo_path)
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    haar_cascade = cv2.CascadeClassifier(
        f"{cv2.data.haarcascades}haarcascade_frontalface_default.xml"
    )

    faces_in_photo = [(int(x), int(y), int(w), int(h)) for (x, y, w, h) in haar_cascade.detectMultiScale(gray_image, 1.1, 9)]
    
    for face in faces_in_photo:
        msg = dict()
        msg['obj_id'] = obj_id
        msg['face'] = face

        client = boto3.client(
            service_name='sqs',
            endpoint_url=os.environ.get("msg_queue_url"),
            region_name='ru-central1',
        )
        client.send_message(
            QueueUrl=os.environ.get("msg_queue_url"),
            MessageBody=json.dumps(msg)
        )

    return {
        'statusCode': 200,
        'body': None
    }