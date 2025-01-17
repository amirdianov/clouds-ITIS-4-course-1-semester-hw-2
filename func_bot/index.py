
import json
import random
import os
import logging
from pathlib import Path
import boto3
import requests


TG_BOT_KEY = os.environ.get("tg_bot_key")
s3_client = boto3.client("s3", endpoint_url="https://storage.yandexcloud.net",)

def send_face_photo(chat_id, name: str, faces: bool = True): 
    url = f"https://api.telegram.org/bot{TG_BOT_KEY}/sendPhoto"
    api_gw = os.environ.get("api_gw_domain")

    photo_url = f"https://{api_gw}/?face={name}" if faces else \
                f"https://{api_gw}/original_photo/?original_photo={name}"

    requests.post(
        url=url,
        data={
            "chat_id": chat_id,
            "photo": photo_url,
            "caption": name
        }
    )

def send_text(chat_id, text: str):
    url = f"https://api.telegram.org/bot{TG_BOT_KEY}/sendMessage"
    
    requests.post(
        url=url,
        data={
            "chat_id": chat_id,
            "text": text,
        }
    )


def handler(event, context):
    print(event)
    data = json.loads(event['body'])

    if "message" not in data:
        return {"statusCode": 200}
    
    message = data['message']
    try:
        if text:= message.get("text"):
            chat_id = message.get("chat").get("id")
            if text == '/getface':
                face_path = Path("/function/storage/vvot25-faces")

                all_faces = [
                    file.name for file in face_path.iterdir()
                    if file.name.startswith("undefined")
                ]

                face = random.choice(all_faces)
                send_face_photo(chat_id=chat_id, name=face)
            
            elif text.startswith("/find"):
                name = " ".join(text.split(' ')[1:])
                originals_photo = []

                for face in Path("/function/storage/vvot25-faces").iterdir():
                    if not name in face.name.split('_')[0]:
                        continue
                    originals_photo.append(
                        face.name[face.name.find('_')+1 : face.name.rfind('_')]
                    )
                
                for original in originals_photo:
                    send_face_photo(chat_id=chat_id, name=original, faces=False)
                

            elif reply:= message.get("reply_to_message"):
                if "photo" in reply:
                    caption = reply.get("caption")

                    splited = caption.split('_')
                    new_name = f"{text}_{'_'.join(splited[1:])}"

                    s3_client.upload_file(
                        Bucket="vvot25-faces",
                        Key=new_name,
                        Filename=f"/function/storage/vvot25-faces/{caption}"
                    )
                    s3_client.delete_object(
                        Bucket="vvot25-faces",
                        Key=caption,
                    )
            else:
                send_text(chat_id, "Произошла ошибка")
    except Exception as e:
        print(e)
        send_text(chat_id, "Произошла ошибка")

    return {
        'statusCode': 200
    }